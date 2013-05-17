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
package de.agra.lips.editor.perspectives

import org.eclipse.ui.IPerspectiveFactory
import org.eclipse.ui.IPageLayout
import de.agra.lips.editor.views.NounClassificationView

/**
 * @brief Class defining the lips perspective
 */
class LipsPerspectiveFactory implements IPerspectiveFactory {
	override createInitialLayout(IPageLayout layout) {
		val editorArea = layout.getEditorArea()

		val leftside = layout.createFolder("leftside", IPageLayout::LEFT, 0.2f, editorArea)
		leftside.addView(IPageLayout::ID_PROJECT_EXPLORER)

		val bottom = layout.createFolder("bottom", IPageLayout::BOTTOM, 0.8f, editorArea)
		bottom.addView(IPageLayout::ID_PROBLEM_VIEW)
		bottom.addView(NounClassificationView::ID)

		val rightside = layout.createFolder("rightside", IPageLayout::RIGHT, 0.7f, editorArea)
		rightside.addView(IPageLayout::ID_OUTLINE)
	}
}