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
package de.agra.lips.editor.commands

import de.agra.lips.editor.editors.NLPEditor
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.WordNetView
import de.agra.nlp.util.WordNetLexicographer
import edu.smu.tspell.wordnet.WordNetDatabase
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.widgets.Control

/**
 * @brief Contains the command to perform a WordNet search 
 */
class WordNetCommand extends AbstractHandler {

	/**
	 * @brief Query WordNet and displays the results
	 * @param event This parameter is ignored
	 */
	override execute(ExecutionEvent event) throws ExecutionException {
		val editor = GuiHelper::activeEditor
		val wordNetView = GuiHelper::findOrOpenView(WordNetView::ID) as WordNetView

		if (wordNetView != null && editor instanceof NLPEditor) {
			val nlpeditor = editor as NLPEditor
			val offset = nlpeditor.viewer.selectedRange.x
			val text = editor.getAdapter(typeof(Control)) as StyledText
			val word = GuiHelper::findWord(offset, text)
			if (word.length > 0) {
				val wordnet = WordNetDatabase::fileInstance
				val synsets = wordnet.getSynsets(word)
				wordNetView.setText(WordNetLexicographer::toString(synsets))
			}
		}
		null
	}
}
