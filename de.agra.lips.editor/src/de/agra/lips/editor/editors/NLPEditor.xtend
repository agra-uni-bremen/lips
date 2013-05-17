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
package de.agra.lips.editor.editors

import de.agra.lips.editor.outline.OutlinePage
import org.eclipse.ui.views.contentoutline.IContentOutlinePage

/**
 * @brief Class that provides the editor for English sentences and NLP
 */
class NLPEditor extends NLPBaseEditor {
    OutlinePage outlinePage = null

public static val ID = "de.agra.lips.editor.editors.NLPEditor"

	override getAdapter(Class adapter) {
		if (adapter == typeof(IContentOutlinePage)) {
			if (outlinePage == null) {
				outlinePage = new OutlinePage
				outlinePage.document = sourceViewer.document
				addToReconciler(outlinePage)
			}
			return outlinePage
		}
		super.getAdapter(adapter)
	}
}