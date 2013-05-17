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

import de.agra.lips.editor.Activator
import de.agra.lips.editor.util.GuiHelper
import de.agra.nlp.semantical.NounClassification
import de.agra.nlp.structural.SimpleStructuralAnalysis
import org.eclipse.jface.text.BadLocationException
import org.eclipse.jface.text.IRegion
import org.eclipse.jface.text.ITextViewer
import org.eclipse.jface.text.Region
import org.eclipse.jface.text.hyperlink.AbstractHyperlinkDetector

class ClassLinkDetector extends AbstractHyperlinkDetector {
	/**
	 * @brief Implements the hyper link detector
	 *
	 * @param textViewer containing the text
	 * @param region region to be inspected
	 * @param canShowMultipleHyperlinks unused parameter
	 *
	 * @return Returns one hyper link or null
	 */
	override detectHyperlinks(ITextViewer textViewer, IRegion region, boolean canShowMultipleHyperlinks) {
		/* ensure that region and textViewer are valid */
		if (region == null || textViewer == null) {
			return null
		}

		/* get document and absolute offset */
		val document = textViewer.document
		val offset = region.offset

		/* ensure that document is valid */
		if (document == null) {
			return null
		}

		/* extract current line */
		var IRegion lineInfo
		var String line
		try {
			lineInfo = document.getLineInformationOfOffset(offset)
			line = document.get(lineInfo.offset, lineInfo.length)
		} catch (BadLocationException e) {
			return null
		}

		/* calculate offset in line and find the word under cursor */
		val innerOffset = offset - lineInfo.offset
		val word = GuiHelper::findWord(innerOffset, line)
		if (word.length <= 0) {
			return null
		}

		/* get normal form of noun */
		val normalNoun = SimpleStructuralAnalysis::nounNormalForm(word)

		/* check whether noun is a class classified noun */
		val classifiedNouns = Activator::^default.nounDB.nounsMap
		if (!classifiedNouns.containsKey(normalNoun) ||
			classifiedNouns.get(normalNoun).classification != NounClassification::Class) {
			return null
		}

		/* find starting offset of the word under cursor */
		val wordOffset = line.indexOf(word, innerOffset - word.length)
		if (wordOffset < 0) {
			return null
		}

		/* build a region that contains the word */
		val urlRegion = new Region(lineInfo.offset + wordOffset, word.length)

		/* create the hyper link and return it */
		#[new ClassLink(document, urlRegion, normalNoun)]
	}
}
