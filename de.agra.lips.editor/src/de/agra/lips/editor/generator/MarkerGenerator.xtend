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

import org.eclipse.core.resources.IFile
import org.eclipse.jface.text.IDocument
import java.util.ArrayList
import java.util.List
import org.eclipse.core.resources.IMarker
import java.util.regex.Pattern
import de.agra.nlp.semantical.Word

/**
 * @brief Generates markers for lists of words
 */
class MarkerGenerator {
	IFile currentFile
	IDocument document

	var markeredWords = new ArrayList<Word>

	/**
	 * @brief Default constructor
	 *
	 * @param file File to which the markers should be attached
	 * @param document Document containing the text
	 */
	new (IFile file, IDocument doc) {
		currentFile = file
		document = doc
	}

	/**
	 * @brief Markers the words in the list
	 *
	 * @param list of words to be markered
	 */
	def public marker(List<Word> words) {
		if (currentFile == null) {
			return
		}

		// only work on words that are not already markered
		for (word : words.filter[!markeredWords.contains(it)]) {
			val pattern = Pattern::compile("\\b" + word.word + "\\b", Pattern::CASE_INSENSITIVE)
			val matcher = pattern.matcher(document.get)
			
			while (matcher.find) {
				val start = matcher.start
				val line = document.getLineOfOffset(start)
				val marker = currentFile.createMarker("de.agra.lips.editor.markers.nounclassificationmarker")
				marker.setAttribute(IMarker::LINE_NUMBER, line + 1)
				marker.setAttribute(IMarker::CHAR_START, start)
				marker.setAttribute(IMarker::CHAR_END, start + word.word.length)
				marker.setAttribute(IMarker::PRIORITY, IMarker::PRIORITY_HIGH)
				marker.setAttribute(IMarker::SEVERITY, IMarker::SEVERITY_WARNING)
				marker.setAttribute(IMarker::MESSAGE, "Cannot classify \"" + word.word + "\"")
				marker.setAttribute("unclassifiedNoun", word)
			}
			markeredWords += word
		}
	}
}
