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

import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.ParsedStructureView
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException

/**
 * @brief Contains the command for saving a parsed structure image
 */
class SaveParsedStructureImageCommand extends AbstractHandler  {

	/**
	 * @brief Saves the displayed parsed structure image to a file
	 * @param event The event stores the information, which image to save
	 */
	override execute(ExecutionEvent event) throws ExecutionException {
		val viewID = event.getParameter("de.agra.lips.editor.commands.parameters.saveview")
		val view = GuiHelper::findView(viewID) as ParsedStructureView

		if (view != null && view.imageDisplayed) {
			val filename = event.getParameter("de.agra.lips.editor.commands.parameters.parsedstructurefilename")
			// note that filename may be null. this is handled by the saveImage function
			view.saveImage(filename)
		}
		null
	}
}
