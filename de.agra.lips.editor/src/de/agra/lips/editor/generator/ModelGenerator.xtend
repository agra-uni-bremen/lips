/*
 * lips
 * Copyright (C) 2013 -- The lips developers
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package de.agra.lips.editor.generator

import de.agra.lips.editor.Activator
import de.agra.lips.editor.providers.LipsDocumentProvider
import de.agra.lips.editor.reconciler.IReconcilingParticipant
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.NounClassificationView
import de.agra.nlp.semantical.Word
import de.agra.nlp.structural.Extractor
import java.util.ArrayList
import java.util.Collections
import java.util.logging.Logger
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IMarker
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMLResourceFactoryImpl
import org.eclipse.emf.ecoretools.diagram.part.EcoreDiagramEditorUtil
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.source.ISourceViewer

/**
 * @brief Class generating the model
 */
class ModelGenerator implements IReconcilingParticipant {
	val ISourceViewer sourceViewer
	var boolean createDiagram = true
	static val logger = Logger::getLogger(typeof(ModelGenerator).name)

	/**
	 * @brief Constructor setting the sourceViewer and createDiagram variable
	 *
	 * @param sourceViewer The sourceViewer this class will use
	 * @param createDiagram Sets whether ECore diagrams should automatically be created
	 */
	new(ISourceViewer sourceViewer, boolean createDiagram) {
		this.sourceViewer = sourceViewer
		this.createDiagram = createDiagram
	}

	/**
	 * @brief Constructor setting the sourceViewer variable, ECore diagrams
	 *        are created automatically when calling this constructor
	 *
	 * @param sourceViewer The sourceViewer this class will use
	 */
	new(ISourceViewer sourceViewer) {
	    this(sourceViewer, true)
	}

	/**
	 * @brief Generates the model for the given document
	 *
	 * @param document The document that contains the sentences that are used
	 * to extract the model.
	 */
	override reconcile(IDocument document) {
		logger.finest("Start reconciling model generator")
		val file = LipsDocumentProvider::instance.getFile(document)
		val modelFileName = file.name.replaceAll("\\.lips$", "")

		logger.finest("Create folder model-gen")
		val folder = createFolder(file.project, "model-gen")
		val modelMerger = new ModelMerger

		logger.finest("Delete existing markers")
		file.deleteMarkers

		logger.finest("Create extractor")
		val extractor = new Extractor
		val parser = Activator::^default.parser

		logger.finest("Create marker generator")
		val markerGenerator = new MarkerGenerator(file, document)

		logger.finest('''Enter the loop over all «document.numberOfLines» sentences in document: «document»''')

		// Iterate over all lines in the document that are sentences
		var line = 0
		while (line < document.numberOfLines) {
			val sentence = document.getTextByLine(line).trim

			if (sentence.isSentence) {
				logger.finest('''Generating model for sentence "«sentence»"''')
			
				val classifiedNouns = Activator::^default.nounDB.nounsMap
				val unknowns = new ArrayList<Word>

				// Extract the model from line and merge it with the current model
				logger.finest("Merge model into base model")
				modelMerger.mergeModel(extractor.extractPackage(classifiedNouns, unknowns, parser, sentence))

				// Create the markers for the unclassified nouns
				logger.finest("Generate markers")
				markerGenerator.marker(unknowns)
			}

			line = line + 1
		}

		logger.finest("Save model")
		saveModel(modelMerger.model, folder, modelFileName)
		
		// After the model has been generated we have to refresh the view on the
		// classified nouns
		val nounView = GuiHelper::findView(NounClassificationView::ID) as NounClassificationView
		nounView?.refresh
	}

	/**
	 * @brief Deletes all markers from the current file
	 */
	def private deleteMarkers(IFile file) {
		file.deleteMarkers(IMarker::PROBLEM, true, IResource::DEPTH_INFINITE)
	}

	/**
	 * @brief Saves a EPackage model
	 *
	 * @param model The model that should be saved
	 * @param folder The folder in which to store the model
	 * @param fileName Name of the file the model is stored in
	 */
	def private saveModel(EPackage model, IFolder folder, String fileName) {
		
		logger.finest('''saveModel(«model»,«folder»,«fileName»)''')
		
		val file = folder.getFile('''model-«fileName».ecore''')
		val modelURI = URI::createURI(file.fullPath.toString)

		val resourceSet = new ResourceSetImpl
		resourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("ecore", new XMLResourceFactoryImpl)

		val resource = resourceSet.createResource(modelURI)
		resource.contents += model
		resource.save(Collections::EMPTY_MAP)

		if (createDiagram) {
			val diagFile = folder.getFile('''model-«fileName».ecorediag''')
			val diagURI = URI::createURI(diagFile.fullPath.toString)
			logger.finest('''createDiagram=«createDiagram» diagURI=«diagURI» modelURI=«modelURI» model=«model»''')
			EcoreDiagramEditorUtil::createDiagramOnly(diagURI, modelURI, model, true, new NullProgressMonitor)
		}
	}

	/**
	 * @brief Creates a "model-gen" folder in the current project folder
	 * @param project The project in which the folder should be created
	 * @param folderName The name of the folder that will be created
	 * @return An IFolder instance if the creation succeeded, null otherwise
	 */
	def private createFolder(IProject project, String folderName) {
		val folder = project.getFolder(folderName)
		if (!folder.exists) {
			folder.create(IResource::NONE, true, null)
		}
		folder
	}

	/**
	 * @brief Checks whether text is a real sentence (in our definition)
	 * @param text The text
	 */
	def private isSentence(String text) {
		text != null && !text.trim.empty && (text.trim.endsWith(".") || text.trim.endsWith("?") || text.trim.endsWith("!"))
	}

	/**
	 * @brief Returns the text of a document given its line
	 *
	 * @param document The document which contains the text
	 * @param line The line in the document (must be valid)
	 * @return The text in the line
	 */
	def private getTextByLine(IDocument document, int line) {
		val region = document.getLineInformation(line)
		document.get(region.offset, region.length)
	}
}
