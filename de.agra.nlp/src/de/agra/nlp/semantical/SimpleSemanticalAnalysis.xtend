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

import de.agra.nlp.util.WordNetLexicographer
import edu.smu.tspell.wordnet.SynsetType
import edu.smu.tspell.wordnet.WordNetDatabase
import edu.smu.tspell.wordnet.impl.file.synset.NounReferenceSynset
import de.agra.nlp.semantical.Word

/**
 * @brief Performs a simple semantical analysis, i.e. classifies a noun
 */
class SimpleSemanticalAnalysis {

	static val ClassList = #[WordNetLexicographer::NOUN_ARTIFACT, WordNetLexicographer::NOUN_OBJECT]
	static val ActorList = #[WordNetLexicographer::NOUN_ANIMAL, WordNetLexicographer::NOUN_PERSON]

	def static classifyNoun(Word noun, String sentence) {
		if (noun.pos == "NNP") {
			return NounClassification::Actor
		} else {
			return classifyNoun(noun.word, sentence)
		}
	}

	def static classifyNoun(String noun, String sentence) {
		val database = WordNetDatabase::fileInstance
		val synsets = database.getSynsets(noun, SynsetType::NOUN)
		if (synsets.size > 0) {
			// choose the synset that represents the sense that is most likely
			// the one fitting to the given sentence
			val synset = WSD::simpleLesk(noun, sentence) as NounReferenceSynset
			val number = synset.lexicalFileNumber

			if (ClassList.contains(number)) {
				NounClassification::Class
			} else if (ActorList.contains(number)) {
				NounClassification::Actor
			} else {
				NounClassification::Unknown
			}
		}
		else {
			NounClassification::Unknown
		}
	}
}
