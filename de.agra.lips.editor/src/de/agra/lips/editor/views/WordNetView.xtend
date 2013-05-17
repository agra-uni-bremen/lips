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

import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.part.ViewPart

/**
 * @brief A view for showing WordNet query results
 */
class WordNetView extends ViewPart {
	public static val ID = "de.agra.lips.editor.views.wordnetview"
	Text label

	override createPartControl(Composite parent) {
		label = new Text(parent, #[SWT::MULTI, SWT::READ_ONLY, SWT::V_SCROLL].reduce[a, b | a.bitwiseOr(b)])
	}

	override setFocus() {
		label.setFocus
	}

	def setText(String text) {
		label.text = text
	}
}
