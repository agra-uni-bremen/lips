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
package de.agra.nlp.util

import edu.smu.tspell.wordnet.SynsetType
import edu.smu.tspell.wordnet.WordNetDatabase
import java.util.logging.Logger

/**
 * @brief Collection of WordNet utilities
 */
class WordNetUtils {
	static val logger = Logger::getLogger(typeof(WordNetUtils).name)

	/**
	 * @brief Retrieves the normal form of a word
	 *
	 * This is done by choosing the first word form returned by WordNet for the
	 * supplied word.
	 *
	 * @param word The word whose normal form should be retrieved
	 * @param type The type of the word (e.g. noun)
	 * @return The normal form of the word or, if none found, the word itself
	 */
	def static getNormalForm(String word, SynsetType type) {
		logger.finest('''Looking for normal form of "«word»"''')

		val candidates = WordNetDatabase::fileInstance.getBaseFormCandidates(word, type)
		var normalForm = candidates.head ?: word

		logger.finest('''Initial form: «normalForm»''')

		if (type == SynsetType::VERB && !candidates.empty) {
			logger.finest('''Word is of type verb. Checking other normal forms''')
			for (c: candidates) {
				logger.finest('''Testing «c»''')
				if (c.endsWith("y")) {
					normalForm = c
				}
			}
		}
		logger.finest('''Logger ''')
		normalForm
	}
}