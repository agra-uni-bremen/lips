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
package de.agra.nlp.util

import edu.stanford.nlp.trees.TypedDependency
import java.util.ArrayList
import java.util.Collection

/**
 * @class TypedDependenciesToGraphViz
 * @brief Class that deals with exporting a typed dependencies to dot
 */
class TypedDependenciesToGraphViz {

	def static toDot(Collection<TypedDependency> graph) {
		val stream = new StringBuilder
		
		// this stores the index of already created nodes to ensure that no
		// node is created more than once. 
		val createdNodes = new ArrayList<Integer>()
		
		var int gindex
		var int dindex
		
		var String dnodename
		var String gnodename
		
		stream.append("digraph \"TypedDependencies\" {\n")
		for (node : graph) {
			gindex = node.gov.index
			dindex = node.dep.index
			
			dnodename=DotHelper::escapeNodeName(node.dep.toString)
			gnodename=DotHelper::escapeNodeName(node.gov.toString)
			
			if (!graph.contains(dindex)) {
				createdNodes.add(dindex)
				stream.append('''	«dnodename» [label="«node.dep.toString.replace("'","\\'")»"];''').append("\n")
			}
			if (!graph.contains(gindex)) {
				createdNodes.add(gindex)
				stream.append('''	«gnodename» [label="«node.gov.toString.replace("'","\\'")»"];''').append("\n")
			}
			stream.append('''	"«gnodename»" -> "«dnodename»" [label="«node.reln»"];''').append("\n")
		}
		stream.append("}").append("\n").toString
	}


	/**
	 * @brief Stores typed dependencies in a png file
	 *
	 * The typed dependencies accepted by this function come from the Stanford
	 * parser.
	 *
	 * @param deps The typed dependencies that will be saved in a dot generated png file
	 * @param filename Path to the output file 
	 */
	def static createImage(Collection<TypedDependency> deps, String filename) {
		DotHelper::createDotImage(toDot(deps),filename)
	}


	/**
	 * @brief Stores typed dependencies in a png file
	 *
	 * The typed dependencies accepted by this function come from the Stanford 
	 * parser.
	 *
	 * The filename is "out.png" which is stored in the current directory.
	 *
	 * @param deps The typed dependencies that will be saved in a dot generated png file
	 */
	def static createImage(Collection<TypedDependency> deps) {
		createImage(deps,"out.png")
	}
}
