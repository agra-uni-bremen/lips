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
package de.agra.lips.editor.hyperlinks

import de.agra.lips.editor.providers.LipsDocumentProvider
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecoretools.diagram.part.EcoreDiagramEditor
import org.eclipse.gef.EditPart
import org.eclipse.gmf.runtime.diagram.ui.editparts.LabelEditPart
import org.eclipse.gmf.runtime.diagram.ui.editparts.ResizableCompartmentEditPart
import org.eclipse.gmf.runtime.diagram.ui.parts.DiagramEditor
import org.eclipse.gmf.runtime.emf.core.util.EMFCoreUtil
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.IRegion
import org.eclipse.jface.text.hyperlink.IHyperlink
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.part.FileEditorInput

class ClassLink implements IHyperlink {
	val IDocument document
	val IRegion region
	val String word
	
	new(IDocument document, IRegion region, String word) {
		this.document = document
		this.region = region
		this.word = word
	}

	override getHyperlinkRegion() {
		region
	}
	
	override getHyperlinkText() {
		"Open ECore diagram for class \"" + word + "\""
	}
	
	override getTypeLabel() {
		null
	}
	
	override open() {
		val folderName = "model-gen"
		val file = LipsDocumentProvider::instance.getFile(document)
		val fName = file.name.replaceAll("\\.lips$", "")

		val folder = file.project.getFolder(folderName.toString)
		if (!folder.exists) { return }

		val diagFile = folder.getFile('''model-«fName».ecorediag''')
		val workspaceResource = ResourcesPlugin::workspace.root.findMember(diagFile.fullPath)
		if (!(workspaceResource instanceof IFile)) { return }

		val page = PlatformUI::workbench.activeWorkbenchWindow.activePage
		val editorPart = page.openEditor(new FileEditorInput(workspaceResource as IFile), EcoreDiagramEditor::ID) as DiagramEditor

		val modelFile = folder.getFile('''model-«fName».ecore''')
		val modelURI = URI::createURI(modelFile.fullPath.toString)
		val resourceSet = new ResourceSetImpl
		resourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("ecore", new EcoreResourceFactoryImpl)
		val resource = resourceSet.getResource(modelURI, true)
		val model = resource.contents.get(0) as EPackage
		var object = model.EClassifiers.filter[it.name == word].head
		
		if (object != null) {
			val proxyId = EMFCoreUtil::getProxyID(object)
			val partsToFilter = editorPart.diagramGraphicalViewer.findEditPartsForElement(proxyId, typeof(EditPart))

			val partsToSelect = partsToFilter
				.filter[!(it instanceof ResizableCompartmentEditPart || it instanceof LabelEditPart)]
				.map[it as EditPart]

			if (!partsToSelect.isEmpty) {
				editorPart.diagramGraphicalViewer.selection = new StructuredSelection(partsToSelect.last)
				editorPart.diagramGraphicalViewer.reveal(partsToSelect.last)
			}
		}
	}
	
}