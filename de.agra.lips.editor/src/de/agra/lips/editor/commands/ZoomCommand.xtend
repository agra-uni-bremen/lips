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

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.ParsedStructureView

/**
 * @brief Contains the command for zooming images 
 */
class ZoomCommand extends AbstractHandler {

	/**
	 * @brief Zooms the displayed image in the PST or dependency graph view
	 * @param event This parameter stores the type of zoom and the view that triggered
	 *        the command
	 */
	override execute(ExecutionEvent event) throws ExecutionException {
		val viewID = event.getParameter("de.agra.lips.editor.commands.parameters.zoomview")
		val cmd = event.getParameter("de.agra.lips.editor.commands.parameters.zoomtype")

		val view = GuiHelper::findView(viewID) as ParsedStructureView
		if (view != null) {
			switch (cmd) {
				case "zoomin":      view.canvas.zoomIn
				case "zoomout":     view.canvas.zoomOut
				case "fittocanvas": view.canvas.fitCanvas
				default:            view.canvas.fitCanvas
			}
		}
		null
	}
}
