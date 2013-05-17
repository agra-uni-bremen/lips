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
package de.agra.nlp

import edu.stanford.nlp.parser.lexparser.LexicalizedParser
import edu.stanford.nlp.trees.Tree
import edu.stanford.nlp.trees.PennTreebankLanguagePack
import edu.stanford.nlp.parser.lexparser.Options

/**
 * @brief Wrapper for the Stanford NLP parser
 */
class StanfordParser {
	val LexicalizedParser parser

	public static val CHINESE_PARSER = "edu/stanford/nlp/models/lexparser/chinesePCFG.ser.gz"
	public static val ENGLISH_PARSER = "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz"
	public static val GERMAN_PARSER = "edu/stanford/nlp/models/lexparser/germanPCFG.ser.gz"

	/**
	 * @brief Creates a parser with the (default) English grammar file
	 */
	new() {
		parser = LexicalizedParser::loadModel
	}

	/**
	 * @brief Creates a parser given a user defined location
	 *
	 * Static variables in this class give ready access to some important parsers
	 */
	new(String parserLocation) {
		parser = LexicalizedParser::loadModel(parserLocation, new Options)
	}

	/**
	 * @brief Parses a text and returns the phrase structure tree
	 */
	def parse(String text) {
		parser.apply(text).skipRoot
	}

	/**
	 * @brief Computes typed dependencies based on phrase structure tree
	 */
	def public static getTypedDependencies(Tree tree) {
		getTypedDependencies(tree, 3)
	}

	/**
	 * @brief Computes typed dependencies based on phrase structure tree
	 */
	def public static getTypedDependencies(Tree tree, int type) {
		val structure = new PennTreebankLanguagePack().grammaticalStructureFactory.newGrammaticalStructure(tree)
		switch type {
			case 1:
				structure.typedDependencies
			case 2:
				structure.typedDependencies(true)
			case 3:
				structure.typedDependenciesCCprocessed
			case 4:
				structure.typedDependenciesCCprocessed(true)
			case 5:
				structure.typedDependenciesCollapsed
			case 6:
				structure.typedDependenciesCollapsed(true)
			case 7:
				structure.typedDependenciesCollapsedTree
			default:
				structure.typedDependenciesCCprocessed(true)
		}
	}

	/**
	 * @brief Alias for StanfordParser::parse
	 */
	def getConstituentTree(String text) {
		parse(text)
	}
}

