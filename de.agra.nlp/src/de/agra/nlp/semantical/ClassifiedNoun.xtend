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
package de.agra.nlp.semantical

import de.agra.nlp.semantical.Word
import java.io.Serializable

/**
 * @brief POJO storing classification information on a noun
 */
class ClassifiedNoun implements Serializable {
	@Property var NounClassification classification
	@Property var ClassificationType type
	@Property val Word word

	def getNoun() {
		word.word
	}
	
	def getPos() {
		word.pos
	}

	new (String noun) {
		this._word = new Word(noun)
		this.classification = NounClassification::Unknown
		this.type = ClassificationType::Automatic
	}

	new (String noun, String pos) {
		this._word = new Word(noun,pos)
		this.classification = NounClassification::Unknown
		this.type = ClassificationType::Automatic
	}

	/**
	 * @brief This constructors simply fills the data fields of this POJO
	 *
	 * @param noun The noun that is classified
	 * @param classification What the noun is classified as
	 * @param type How the noun was classified
	 */
	new(String noun, NounClassification classification, ClassificationType type) {
		this._word = new Word(noun)
		this.classification = classification
		this.type = type
	}

	/**
	 * @brief This constructors simply fills the data fields of this POJO
	 *
	 * @param noun The noun that is classified
	 * @param classification What the noun is classified as
	 * @param type How the noun was classified
	 */
	new(String noun, NounClassification classification) {
		this._word = new Word(noun)
		this.classification=classification
		this.type=ClassificationType::Automatic
	}

	/**
	 * @brief This constructors simply fills the data fields of this POJO
	 *
	 * The type of classification is set to Automatic
	 *
	 * @param w Word object that is stored
	 * @param classification The classification of the word
	 */
	new (Word w, NounClassification classification) {
		this._word = w
		this.classification=classification
		this.type=ClassificationType::Automatic
	}

	/**
	 * @brief This constructors simply fills the data fields of this POJO
	 *
	 * The type of classification is set to Automatic
	 *
	 * @param word Word object that is stored
	 * @param classification The classification of the word
	 * @param type How the noun was classified
	 */
	new (Word word, NounClassification classification, ClassificationType type) {
		this._word = word
		this.classification=classification
		this.type=type
	}

	/**
	 * @brief Simple string representation of the classified noun
	 *
	 * @return String of form "(noun,classification,type)"
	 */
	override toString() {
		'''(«noun»,«classification.toString»,«type.toString»)'''
	}
}
