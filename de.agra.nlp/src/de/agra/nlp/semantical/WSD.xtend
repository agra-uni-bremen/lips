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

import edu.smu.tspell.wordnet.Synset
import edu.smu.tspell.wordnet.SynsetType
import edu.smu.tspell.wordnet.WordNetDatabase
import java.util.Arrays
import java.util.Set

/**
 * @brief Class for performing word sense disambiguation
 */
class WSD {
	/**
	 * @brief Simplified Lesk algorithm for word sense disambiguation
	 *
	 * @note Currently the algorithm is restricted to nouns
	 * @note The parameter word must be contained in sentence. This function does
	 * *not* perform any sanity checks!
	 *
	 * @param word The word whose sense is of interest
	 * @param sentence The context of the word in question. This usually is the 
	 * sentence containing the word.
	 *
	 * @return The entry of the word's synset that best matches the word sense (or
	 * null if the word was not found in WordNet)
	 */
	def static simpleLesk(String word, String sentence) {
		val database = WordNetDatabase::fileInstance
		val synsets = database.getSynsets(word, SynsetType::NOUN)

		val context = sentence.split(" ").toSet
		context.removeUnwantedWords

		var int maxOverlap = 0
		var int bestSense = -1

		var maxTagCount = 0
		var i = 0

		// First guess for the word sense: most frequent sense
		for (s : synsets) {
			var tagCount = s.getTagCount(s.wordForms.head)

			// This is to ensure that for really strange words some
			// "best" sense is chosen 
			if (tagCount == 0 && synsets.size == 1) {
				tagCount = 1
			}
			if (tagCount > maxTagCount) {
				maxTagCount = tagCount
				bestSense = i
			}
			i = i + 1
		}

		/*
		 * Now fetching the synset entry with most overlaps
		 */
		i = 0
		for (s : synsets) {
			val ol = overlap(s, context)
			if (ol > maxOverlap) {
				maxOverlap = ol
				bestSense = i
			}
			i = i + 1
		}
		
		if (bestSense > -1) {
			synsets.get(bestSense)
		} else {
			null
		}
	}

	def private static overlap(Synset syn,Set<String> context) {
		/*
		 * This adds all the words of the examples and the definition of the word.
		 * Parentheses of the glosses are removed.
		 */
		val signature = syn.usageExamples.join(" ").replaceAll("\"", "").split(" ").toSet

		signature.addAll(syn.definition.replaceAll("\\(|\\)", "").split(" ").toSet)
		signature.removeUnwantedWords

		context.filter[signature.contains(it)].size
	}
	
	/**
	 * @brief Removes words that should not be considered for WSD
	 *
	 * These words are either too short (<3 letters) or are manually excluded.
	 *
	 * @todo The heuristic for ignoring words should be enhanced
	 *
	 * @param words The set of words that will be thinned
	 */
	def private static removeUnwantedWords(Set<String> words) {
		val iter = words.iterator

		// words chosen by looking at examples
		val ignoredWords=Arrays::asList("the", "was", "that", "went", "into")

		// only keep words of reasonably length
		// should also remove "the" etc.
		while (iter.hasNext) {
			val word = iter.next
			if (word.length < 3 || ignoredWords.contains(word)) { iter.remove }
		}
	}
}
