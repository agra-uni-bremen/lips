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
package de.agra.lips.editor.outline

import de.agra.lips.editor.Activator
import de.agra.nlp.StanfordParser
import edu.stanford.nlp.trees.TypedDependency
import java.util.ArrayList
import de.agra.nlp.util.SimpleDep

class OutlineCategory {
	@Property var String name

	// Contains the sentence on that line
	@Property var String text
	@Property var OutlineTree tree
	@Property var Iterable<SimpleDep> simpleDependencies

	new(String n, String t) {
		name = n
		text = t

		val parser = Activator::^default.parser

		// This works for both English and German
		val tmpTree = parser.parse(t).skipRoot
		tree = new OutlineTree(tmpTree)

		simpleDependencies =
			(StanfordParser::getTypedDependencies(tmpTree, 1) ?: new ArrayList<TypedDependency>)
				.map[new SimpleDep(it)]
	}

	override toString() {
		name
	}
}
