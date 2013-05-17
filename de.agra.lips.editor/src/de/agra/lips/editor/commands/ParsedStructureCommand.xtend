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

import de.agra.lips.editor.editors.NLPBaseEditor
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.ParsedStructureView
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException

/**
 * @brief Contains the command for parsing a line of text and displaying the
 * resulting dependency graph or PST
 */
class ParsedStructureCommand extends AbstractHandler {
	
	/**
	 * @brief Parses a line of text and displays the resulting dependency graph or PST
	 * @param event Stores the information what kind of parsed structure should
	 *        be created.
	 */
	override execute(ExecutionEvent event) throws ExecutionException {
		val viewID = event.getParameter("de.agra.lips.editor.commands.parameters.strucview")
		val view = GuiHelper::findOrOpenView(viewID) as ParsedStructureView
		val editor = GuiHelper::activeEditor
		if (view != null && editor instanceof NLPBaseEditor) {
			val nlpeditor = editor as NLPBaseEditor
			view.text = GuiHelper::getLineFromViewer(nlpeditor.viewer)
		}
		null
	}
}
