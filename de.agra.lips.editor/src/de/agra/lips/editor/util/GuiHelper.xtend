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
package de.agra.lips.editor.util

import de.agra.lips.editor.editors.NLPEditor
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.swt.custom.StyledText
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.PlatformUI

/**
 * @brief Class that combines some static helper methods for dealing with GUI stuff
 */
class GuiHelper {
	
	/**
	 * @brief Returns the active editor window
	 * @return Reference to the active editor window or null
	 */
	def static getActiveEditor() {
		PlatformUI::workbench.activeWorkbenchWindow.activePage.activeEditor
	}
	
	/**
	 * @brief Searches for a view
	 * @param id The id of the view
	 * @return A reference to the view or null
	 */
	def static findView(String id) {
		PlatformUI::workbench.activeWorkbenchWindow.activePage.findView(id)
	}
	
	/**
	 * @brief Returns an ArrayList of all open NLP editors
	 *
	 * @return List of all open NLP editors
	 */
	def static getNLPEditors() {
		PlatformUI::workbench.activeWorkbenchWindow.activePage.editorReferences
			.filter[it.id.equals(NLPEditor::ID)]
			.map[it.getEditor(true) as NLPEditor]
	}
	
	/**
	 * @brief Searches and opens a view
	 *
	 * In contrast to findView this function tries to open the desired view, if
	 * it not present.
	 *
	 * @param id The id of the view
	 * @return A reference to the view or null
	 */
	def static findOrOpenView(String id) {
		return PlatformUI::getWorkbench.getActiveWorkbenchWindow.getActivePage.showView(id);
	}
	
	
	/**
	 * @brief Extracts the current line of an viewer
	 *
	 * @param viewer the viewer of the editor whose line should be retrieved
	 * @return the currently selected line
	 */
	def static getLineFromViewer(ISourceViewer viewer) {
		val x = viewer.selectedRange.x
		val lines = viewer.document.get.split("\n")
		val lineNumber = viewer.document.getLineOfOffset(x)
		return lines.get(lineNumber)
	}
	
	
	/**
	 * @brief Returns the word under or next to the cursor
	 * 
	 * @param offset The position of the cursor within the text
	 * @param text The text that contains the word
	 */
	def static findWord(int offset, StyledText text) {
		val lineIndex = text.getLineAtOffset(offset)
		val offsetInLine = (offset - text.getOffsetAtLine(lineIndex)) - 1
		val line = text.getLine(lineIndex)
		findWord(offsetInLine, line)
	}
	
	/**
	 * @brief Returns the word under or next to the cursor
	 * 
	 * @param offset The position of the cursor within the text
	 * @param text The text that contains the word
	 */
	def static findWord(int offsetInLine, String line) {
		var word = new StringBuilder
		val len = line.length
		if (len > 0 && offsetInLine < len) {
			/* backward search */
			var i = offsetInLine
			while (i >= 0 && Character::isAlphabetic(line.charAt(i))) {
				word.append(line.charAt(i))
				i = i - 1
			}
			word = word.reverse
			
			/* forward search */
			i = offsetInLine + 1
			while (i < line.length && Character::isAlphabetic(line.charAt(i))) {
				word.append(line.charAt(i))
				i = i + 1
			}
		}
		word.toString
	}

	/**
	 * @brief Creates a foldername from a filename
	 *
	 * The resulting foldername is <filename without .lips extension>-model-gen
	 *
	 * @note This result of this method will be unintuitive if for some reason
	 * the title of the editor window does not match the filename of the file
	 * edited by the editor 
	 *
	 * @param editor The editor
	 * @return Folder name generated from the editor
	 */
	def static getModelFolderName(IEditorPart editor) {
		'''«editor.title.replaceAll("\\.lips$", "")».model-gen'''
	}
}