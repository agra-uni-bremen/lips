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

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EReference

class ModelMerger {
	var EPackage currentModel = null
	val factory = EcoreFactory::eINSTANCE

	/**
	 * @brief Initialize with no model
	 */
	new() {
	}

	/**
	 * @brief Initialize with an initial model
	 */
	new(EPackage model) {
		currentModel = model
	}

	/**
	 * @brief Returns whether a model has been added
	 *
	 * @return Return value is false if and only if no model has been added so far
	 */
	def hasModel() {
		currentModel != null
	}

	/**
	 * @brief Returns the current model
	 *
	 * @return The current model, maybe null if no model has been added so far
	 */
	def model() {
		currentModel
	}

	/**
	 * @brief Merges new model
	 *
	 * @param newModel new model to be added
	 */
	def mergeModel(EPackage newModel) {
		if (!hasModel) {
			currentModel = newModel
		} else {
			newModel.EClassifiers.map[it as EClass].forEach[createClass]
			newModel.EClassifiers.map[it as EClass].forEach[mergeClass]
		}
	}

	/**
	 * @brief Creates shells for the classes without the actual content
	 *
	 * This is needed for referencing
	 *
	 * @param Classifier from the model (will be copy-created)
	 */
	private def void createClass(EClass newClassifier) {
		if (currentModel.EClassifiers.filter[it.name == newClassifier.name].empty) {
			currentModel.EClassifiers += factory.createEClass => [
				name = newClassifier.name
			]
		}
	}

	/**
	 * @brief Merges a class to the current model
	 */
	private def void mergeClass(EClass newClassifier) {
		// classifier will not be null
		val classifier = currentModel.EClassifiers.map[it as EClass].findFirst[it.name == newClassifier.name]

		newClassifier.EAttributes.forEach[mergeAttribute(classifier, it)]
		newClassifier.EReferences.forEach[mergeReference(classifier, it)]
		newClassifier.EOperations.forEach[mergeOperation(classifier, it)]
	}

	/**
	 * @brief Merges attributes from a class to the current model
	 */
	private def void mergeAttribute(EClass classifier, EAttribute attribute) {
		val classAttribute = classifier.EAttributes.findFirst[it.name == attribute.name]

		if (classAttribute != null) {
			if (classAttribute.EType != attribute.EType) {
				// TODO warning about different types
			}
		} else {
			classifier.EStructuralFeatures += attribute
		}
	}

	/**
	 * @brief Merges references from a class to the current model
	 */
	private def void mergeReference(EClass classifier, EReference reference) {
		if (classifier.EReferences.filter[it.name == reference.name].empty) {
			val newReference = factory.createEReference => [
				name = reference.name
				lowerBound = reference.lowerBound
				upperBound = reference.upperBound
			]

			val referenceType = currentModel.EClassifiers.findFirst[it.name == reference.EType.name]
			if (referenceType != null) {
				newReference.EType = referenceType
			} else {
				// TODO implement some checks
			}

			classifier.EStructuralFeatures += newReference
		} else {
			// TODO implement some checks
		}
	}

	/**
	 * @brief Merges operations from a class to the current model
	 */
	private def void mergeOperation(EClass classifier, EOperation operation) {
		if (classifier.EOperations.filter[it.name == operation.name].empty) {
			val newOperation = factory.createEOperation => [name = operation.name]

			for (parameter : operation.EParameters) {
				val newParameter = factory.createEParameter => [name = parameter.name]

				val paramType = currentModel.EClassifiers.findFirst[it.name == parameter.EType.name]
				if (paramType != null) {
					newParameter.EType = paramType
				} else {
					// TODO implement some checks
				}

				newOperation.EParameters += newParameter
			}
			classifier.EOperations += newOperation
		} else {
			// TODO implement some checks
		}
	}
}
