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

import edu.stanford.nlp.trees.Tree
import java.util.ArrayList

/**
 * @brief Class that deals with exporting a Stanford PST to the dot format
 */
class StanfordExporter {
	/**
	 * @brief Creates dot code for the visualization of a Stanford Tree
	 * @param Tree The Stanford Tree
	 *
	 * @returns The dot code for the tree
	 */
	def static String toDot(Tree tree) {
		val s = new StringBuilder
		val counter = 0
		val leaves = new ArrayList<String>

		s.append('''graph "ConstituentTree" {''').append("\n")
		val String startingNode = '''«tree.label.value»«counter»'''
		s.append('''«DotHelper::escapeNodeName(startingNode)»[label="«tree.label.value»"]''').append(";\n")
		toTreeHelperDot(tree, "\t", counter, s, leaves)

		s.append("\t{ rank = same;\n")
		leaves.forEach[s.append("\t\t" + it + ";\n")]
		s.append("\t}")
		s.append("}\n")
		s.toString
	}

	/**
	 * @brief Recursively adds nodes and leaves to the dot StringBuilder
	 *
	 * @param tree The currently used (sub)tree
	 * @param indent String that will be prepended at each added line
	 * @param counter Counts the nodes to ensure a unique nodename in the dot-file
	 * @param s StrindBuilder that will eventually contain the whole dot description of the tree
	 * @param leaves ArrayList that contains all the leaves. As these should be
	 * placed on the same rank, this has to be added later on (outside of this
	 * function)
	 */
	def private static void toTreeHelperDot(Tree tree, String indent, int counter, StringBuilder s, ArrayList<String> leaves) {
		var next_counter = counter

		for (c: tree.children) {
			next_counter = next_counter + 1

			val source ='''«DotHelper::escapeNodeName(tree.label.value)»«counter»'''
			val target ='''«DotHelper::escapeNodeName(c.label.value)»«next_counter»'''

			var boxed = ""
			if (c.leaf) {
				boxed = " ,shape=box"
				leaves.add(source.toString)
			}

			// create the taget
			s.append('''«indent»«target» [label="«c.label.value.replace("'","\\'")»"«boxed»]''').append(";\n")

			// link to the target
			s.append('''«indent»«source» -- «target»''').append(";\n")

			toTreeHelperDot(c, indent + "\t", next_counter, s, leaves)
		}
	}

	/**
	 * @brief Stores a PST in a png image
	 *
	 * The image stored in the temp folder and is named "tmp_tree.png"
	 *
	 * @param tree The PST that should be saved
	 *
	 * @return The path to the created image
	 */
	def static createImage(Tree tree) {
		createImageFullPath(tree, System::getProperty("java.io.tmpdir") + "/tmp_tree")
	}

	/**
	 * @brief Stores a PST in a png image
	 *
	 * The image is stored in the temp folder. Just specify a filename without
	 * a file extension.
	 *
	 * If you want to specify where the image should be stored use the createImageFullPath
	 * method.
	 *
	 * @param tree The tree that should be saved
	 * @param type What kind of image should be created
	 * @param fileName The name of the resulting image
	 *
	 * @return The path to the created image
	 */
	def static createImage(Tree tree, String fileName) {
		createImageFullPath(tree, System::getProperty("java.io.tmpdir") + "/" + fileName)
	}

	/**
	 * @brief Stores a PST in a png image
	 *
	 * Do not append a file extension to the fullPath. The image will alawys be
	 * a PNG image with a trailing ".png" as the filename.
	 *
	 * @param tree The tree that should be saved
	 * @param type What kind of image should be created
	 * @param fullPath The full path to the place, the image should be stored
	 *
	 * @return The path to the created image
	 */
	def static createImageFullPath(Tree tree, String fullPath) {
		val fNamePNG = fullPath + ".png"
		DotHelper::createDotImage(toDot(tree), fNamePNG)
		
		fNamePNG
	}
}
