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
package de.agra.nlp.structural

import de.agra.nlp.StanfordParser
import de.agra.nlp.semantical.ClassifiedNoun
import de.agra.nlp.semantical.NounClassification
import de.agra.nlp.semantical.SimpleSemanticalAnalysis
import de.agra.nlp.semantical.Word
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import edu.stanford.nlp.trees.Tree
import java.util.logging.Logger

/**
 * @brief Realizes the extraction of nouns from an English sentence
 */
class Extractor {
	val factory = EcoreFactory::eINSTANCE
	static val logger = Logger::getLogger(typeof(Extractor).name)

	/**
	 * @brief Extracts an EPackage from a PST
	 *
	 * The EPackage contains all the EClasses (i.e. Classes for an implementation
	 * of the spec) that could be extracted from the sentence.
	 *
	 * @param alreadyKnownNouns List of nouns that are already known (but not necessarily classified)
	 * @param unknowns List of nouns that could not be classified (implicit return value)
	 * @param sentence The original sentence that was parsed
	 * @return List of EClasses that represent the found classes in the sentence
	 */
	def extractPackage(HashMap<String,ClassifiedNoun> alreadyKnownNouns, List<Word> unknowns, StanfordParser parser, String sentence) {
		val pkg = factory.createEPackage
		pkg.name = "Spec"

		logger.finest('''Parsing "«sentence»"''')
		val tree = parser.parse(sentence)

		logger.finest("Extracting classes")
		val classes = extractClasses(parser, alreadyKnownNouns, unknowns, sentence, tree)
		logger.finest("Adding classes")
		pkg.EClassifiers += classes

		logger.finest("Adding operations")
		addOperations(classes, tree)

		logger.finest("Adding associations")
		addAssociations(classes, tree)
		pkg
	}

	/**
	 * @brief Adds a noun to the list of EClasses
	 *
	 * @param classes List of classes that should contain the noun
	 * @param noun The noun that is added to the list of classes
	 */
	def private addClass(ArrayList<EClass> classes, String noun) {
		logger.finest('''Adding class "«noun»"''')
		val cls = factory.createEClass
		cls.name = noun
		classes += cls
	}

	/**
	 * @brief Extracts classes from a PST
	 *
	 * Nouns that are classified as NounClassification::Unknown are stored in
	 * the input parameter unknowns
	 *
	 * @param alreadyKnownNouns List already known (but not necessarily classified) nouns
	 * @param unknowns List of nouns that could not be classified
	 * @param sentence The sentence that is parsed
	 * @param We need to parse in advance, thus tree exists already
	 *
	 * @return List of found classes
	 */
	def private extractClasses(StanfordParser parser, HashMap<String, ClassifiedNoun> alreadyKnownNouns, List<Word> unknowns, String sentence, Tree tree) {
		val nouns = SimpleStructuralAnalysis::extractNouns(tree)
		val classes = new ArrayList<EClass>
		
		nouns.forEach[noun |
			if (classes.map[it.name].contains(noun.word)) {
				// do nothing
			} else if (alreadyKnownNouns.containsKey(noun.word)) {
				val entry = alreadyKnownNouns.get(noun.word)
				switch (entry.classification) {
					case NounClassification::Class: {
						addClass(classes, noun.word)
					}
					case NounClassification::Unknown: {
						classifyNoun(classes, noun, unknowns, alreadyKnownNouns, sentence)
					}
				}
			} else {
				classifyNoun(classes, noun, unknowns, alreadyKnownNouns, sentence)
			}
		]

		/* Attributes */
		val adjectives = SimpleStructuralAnalysis::extractAdjectives(tree)

		classes.filter[adjectives.containsKey(it.name)].forEach[ cls |
			adjectives.get(cls.name).forEach[attr |
				cls.addAttribute(attr, EcorePackage::eINSTANCE.EBoolean)
			]
		]

		val id_classes = SimpleStructuralAnalysis::extractIDs(parser, sentence)

		classes.filter[id_classes.contains(it.name)].forEach[cls |
			cls.addAttribute("id", EcorePackage::eINSTANCE.EInt)
		]

		classes
	}


	
	def private classifyNoun(ArrayList<EClass> classes, Word noun,
	                         List<Word> unknowns, HashMap<String,ClassifiedNoun> nouns, String sentence) {
		switch (SimpleSemanticalAnalysis::classifyNoun(noun,sentence)) {
			case NounClassification::Class: {
				// store the class in the classes for the EMF output
				addClass(classes,noun.word)
				
				// also store the information within the original hash map
				nouns.put(noun.word,new ClassifiedNoun(noun,NounClassification::Class))
			}
			case NounClassification::Actor: {
				nouns.put(noun.word,new ClassifiedNoun(noun,NounClassification::Actor))
			}
			case NounClassification::Unknown: {
				unknowns.add(noun)
			} 
			default: {
				unknowns.add(noun)
			}
		}
	}

	def private addAttribute(EClass cls, String name, EClassifier type) {
		val eattr = factory.createEAttribute
		eattr.EType = type
		eattr.name = name
		cls.EStructuralFeatures += eattr
	}

	/**
	 * @brief Method encapsulation the creation of an EOperation
	 *
	 * This function's role is simply to reduce code clutter
	 *
	 * @param name The name of the EOperation
	 * @return EOperation with the given name
	 */
	def private createOperation(String name) {
		val eop = factory.createEOperation
		eop.name = name
		logger.finest('''Created operation "«name»"''')
		eop
	}

	/**
	 * @brief Add operations
	 * @param classes
	 * @param tree PST containing a sentence with operations
	 */
	def private addOperations(List<EClass> classes, Tree tree) {
		/* Methods */
		val verbs = SimpleStructuralAnalysis::extractVerbs(tree)

		classes.filter[verbs.containsKey(it.name)].forEach[cls |
			logger.finest('''Adding operations to class "«cls.name»"''')
			verbs.get(cls.name).forEach[addOperation(cls, it, classes)]
		]
	}

	def private addOperation(EClass cls, Pair<String, String> verbObject, List<EClass> classes) {
		val eop = createOperation(verbObject.key)
		cls.EOperations += eop
		if (verbObject.value != null && !classes.filter[it.name == verbObject.value].empty) {
			val param = factory.createEParameter
			// TODO: Don't know how to add a class type as parameter type (Mathias)
			param.name = verbObject.value.toLowerCase
			// This works fine? (Oliver) Should probably be the return type though
			param.EType = classes.filter[it.name == verbObject.value].head
			logger.finest('''Parameter "«param.name»": type=«param.EType» ''')
			eop.EParameters += param
		}
	}

	/**
	 * @brief Checks whether both association ends exist
	 */
	def private bothAssociationEndsExist(List<EClass> classes, ExtractedAssociation association) {
		!classes.filter[it.name == association.parent].empty &&
		!classes.filter[it.name == association.child].empty
	}

	def private addReference(EClass cls, String name, EClass type, boolean isMany) {
		val eattr = factory.createEReference
		eattr.EType = type
		eattr.name = name
		eattr.lowerBound = if (isMany) 0 else 1
		eattr.upperBound = if (isMany) -1 else 1
		cls.EStructuralFeatures += eattr
	}

	def private addAssociations(List<EClass> classes, Tree tree) {
		val associations = SimpleStructuralAnalysis::extractAssociations(tree)

		associations.filter[bothAssociationEndsExist(classes, it)].forEach[association|
			val parent = classes.filter[it.name == association.parent].head
			val child = classes.filter[it.name == association.child].head

			parent.addReference(child.name.toLowerCase, child, association.isMany)
		]
	}
}
