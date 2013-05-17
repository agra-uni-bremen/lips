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
package de.agra.lips.editor.views

import java.io.File
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart

/**
 * @brief A common super class for parsed structures
 */
class ParsedStructureView extends ViewPart {
	ImageCanvas canvas

	override createPartControl(Composite parent) {
		canvas = new ImageCanvas(parent)
	}

	override setFocus() {
		canvas.setFocus
	}

	/**
	 * @brief Returns the canvas
	 */
	def getCanvas() {
		canvas
	}

	/**
	 * @brief Displays an image
	 *
	 * @param filename Path to the file that should be displayed
	 */
	def setImage(String filename) {
		if (new File(filename).exists) {
			canvas.loadImage(filename)
		}
	}

	// dummy function that is not actually used
	def void setText(String s) {
		println(s)
	}

	/**
	 * @brief Checks if there is an images displayed by the canvas
	 */
	def isImageDisplayed() {
		canvas.imageDisplayed
	}

	/**
	 * @brief Saves the image displayed by the canvas to a file
	 */
	def saveImage() {
		canvas.saveImage
	}

	/**
	 * @brief Saves the image displayed by the canvas to a file
	 * @param filename File to which the image is saved
	 */
	def saveImage(String filename) {
		canvas.saveImage(filename)
	}
}
