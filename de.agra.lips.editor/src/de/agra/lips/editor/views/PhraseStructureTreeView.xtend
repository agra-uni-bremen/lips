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

import de.agra.lips.editor.Activator
import de.agra.nlp.util.StanfordExporter

/**
 * @brief A view for phrase structure trees
 */
class PhraseStructureTreeView extends ParsedStructureView {
	public static val ID = "de.agra.lips.editor.views.pst"

	override setText(String text) {
		if (text != null && !text.trim.isEmpty) {
			image = StanfordExporter::createImage(
				Activator::^default.parser.parse(text),
				"PST" // note: no trailing file extension!
			)
		}
    }
}