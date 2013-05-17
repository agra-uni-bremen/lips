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

import java.io.Serializable

/**
 * @brief POJO storing a word an its part-of-speech (POS)
 */
class Word implements Serializable {
	@Property val String word
	@Property val String pos

	/**
	 * @brief Creates a new word with its POS
	 *
	 * @param w The word
	 * @param p The word's POS
	 */
	new(String w, String p) {
		_word = w
		_pos = p
	}
	
	/**
	 * @brief Creates a word with no POS
	 *
	 * @param w The word
	 */
	new (String w) {
		this(w, "")
	}

	override toString() {
		'''(«word»,«pos»)'''
	}

	override equals(Object o) {
		switch (o) {
			Word:    pos.equals(o.pos) && word.equals(o.word)
			default: false
		}
	}
}
