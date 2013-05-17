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

import java.io.PrintStream

class DotHelper {
	/**
	 * @brief Escapes characters that interfere with dot
	 *
	 * It is used to ensure that a node name is a valid specifier for dot
	 *
	 * @param name name for a dot node
	 * @return node name with all problematic characters escaped
	 */
	def static escapeNodeName(String name) {
		var result = name

		for (e : #{"." -> "point", "$" -> "dollar", "-" -> "minus",
		           "," -> "comma", ":" -> "colon", ";" -> "semicolon",
		           "#" -> "hash", "'" -> "apostrophe"}.entrySet) {
			result = result.replace(e.key, e.value)
		}

		// prepend "t" as nodes must not start with a digit
		"t" + result
	}

	/**
	 * @brief Creates PNG image at location filename from dotCode
	 */
	def static createDotImage(String dotCode, String filename) {
		val process = new ProcessBuilder("dot", "-Tpng", "-o" + filename).start
		val stream = new PrintStream(process.outputStream)
		stream.print(dotCode)
		stream.close
		process.waitFor
	}
}
