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
package de.agra.nlp.structural

import de.agra.nlp.StanfordParser
import de.agra.nlp.semantical.Word
import de.agra.nlp.util.WordNetUtils
import edu.smu.tspell.wordnet.SynsetType
import edu.stanford.nlp.ling.TaggedWord
import edu.stanford.nlp.trees.PennTreebankLanguagePack
import edu.stanford.nlp.trees.Tree
import edu.stanford.nlp.trees.TreeGraphNode
import edu.stanford.nlp.trees.TypedDependency
import edu.stanford.nlp.util.StringUtils
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.List
import java.util.logging.Logger
import org.eclipse.xtext.xbase.lib.Pair
import de.agra.nlp.structural.ExtractedAssociation

class SimpleStructuralAnalysis {
	static val logger = Logger::getLogger(typeof(SimpleStructuralAnalysis).name)

	/**
	 * @brief Returns all nouns of a given PST
	 *
	 * @Note The initial version of this function only returned regular nouns.
	 * This behavior was modified to also return proper nouns.
	 *
	 * @param tree Phrase Structure Tree, possibly containing nouns
	 * @return List of extracted nouns (as Strings)
	 */
	def static extractNouns(Tree tree) {
		tree.taggedYield.filter[isNoun].map[makeNormalWord]
	}

	def static nounNormalForm(String word) {
		StringUtils::capitalize(WordNetUtils::getNormalForm(word, SynsetType::NOUN))
	}

	private def static isNoun(TaggedWord word) {
		word.tag.startsWith("NN")
	}

	private def static isAdjective(TaggedWord word) {
		word.tag == "JJ"
	}

	private def static isVerb(TaggedWord word) {
		#["VBZ", "VBG", "VBD", "VB"].contains(word.tag)
	}

	/**
	 * @brief Creates a Word instance with a noun in normal form
	 */
	private def static makeNormalWord(TaggedWord word) {
		new Word(word.word.nounNormalForm, word.tag)
	}

	def static extractAdjectives(Tree tree) {
		
		logger.fine("Extracting adjectives")
		val result = new HashMap<String, List<String>>

		val nounParts = tree.preOrderNodeList.filter[it.value.equals("NP") && it.preOrderNodeList.filter[it.value.equals("NP")].size == 1]
		nounParts.forEach[np |
			np.taggedYield.filter[isAdjective].map[it.word].forEach[adj |
				np.taggedYield.filter[isNoun].map[it.word.nounNormalForm].forEach[noun |
					if (!result.containsKey(noun)) {
						result.put(noun, new ArrayList<String>)
					}
					result.get(noun) += adj
				]
			]
		]

		result
	}

	def static extractVerbs(Tree tree) {
		logger.fine("Extracting verbs")
		val result = new HashMap<String, List<Pair<String, String>>>

		val typedDeps = new PennTreebankLanguagePack().grammaticalStructureFactory.newGrammaticalStructure(tree).typedDependenciesCCprocessed
		typedDeps.filter[it.reln.shortName == "nsubj"].forEach[ t |
			val verb = t.gov.value
			val noun = t.dep.value.nounNormalForm

			val verbWord = tree.taggedYield.filter[it.word == verb].head
			logger.finest('''typedDep="«t»" verb="«verb»" noun="«noun»" verbWord="«verbWord»"''')
			if (isVerb(verbWord)) {
				logger.finest('''«verb» is a verb''')
				if (!result.containsKey(noun)) {
					result.put(noun, new ArrayList<Pair<String, String>>)
				}

				val objNoun = typedDeps
				                .filter[it.reln.shortName == "dobj" && it.gov.value == verb]
				                .head
				logger.finest('''direct object noun is "«objNoun»"''')
				val tmp = (WordNetUtils::getNormalForm(verb, SynsetType::VERB) -> if (objNoun != null) objNoun.dep.value.nounNormalForm)
				logger.finest('''Adding "«tmp»" as operation''')
				result.get(noun) += tmp
			}
		]

		result
	}

	/**
	 * @brief Extract IDs after nouns, e.g. Customer chooses product 12
	 */
	def static extractIDs(StanfordParser parser, String sentence) {
		/* Identifiers in nouns often lead to wrong phrase structure trees. As an
		 * example in the sentence «I press the key 10» the word «key» is detected
		 * as adjective. However, if the 10 is removed, «key» is correctly determined
		 * as noun.
		 *
		 * The idea is as follows. First we check for words labeled CD to get
		 * the natural numbers in the sentence. Then we remove that word from the sentence
		 * and check whether the word appearing right before becomes a noun.
		 * If that is the case, the ID is assigned to that noun.
		 */

		// First we parse the sentence. We have the parser directly in this call because
		// we need to parse different sentences in this routine.
		val tree = parser.parse(sentence)

		// For each CD we store its index in the sentence and the start and end position.
		val found_ids = new ArrayList<Pair<Integer, Pair<Integer, Integer>>>

		tree.taggedYield.forEach[element, index |
			// Indexes at the beginning of a sentence are ignored.
			if (element.tag.equals("CD") && index > 0) {
				found_ids += index -> (element.beginPosition -> element.endPosition)
			}
		]

		// And remove the IDs
		var restr_sentence = sentence
		for (id : found_ids.reverseView) {
			restr_sentence = restr_sentence.substring(0, id.value.key) + restr_sentence.substring(id.value.value)
		}

		// Parse the new sentence
		val restr_tree = parser.parse(restr_sentence)

		// Since we removed some words the indexes of the original words are not the same anymore.
		val result = new ArrayList<String>
		var index_adjustment = 1
		val tags = restr_tree.taggedYield
		for (id : found_ids) {
			val tag = tags.get(id.key - index_adjustment)
			if (tag.tag.startsWith("NN")) {
				result += tag.word.nounNormalForm
			}
			index_adjustment = index_adjustment + 1
		}

		result
	}

	/**
	 * @brief Dependency relations that indicate an association
	 */
	static val associationRelations = #["prep_from", "prep_of", "poss"]

	/**
	 * @brief Determiners that indicate a to-many association
	 */
	static val toManyDeterminers = #["some", "a", "an"]

	/**
	 * @brief Checks whether dep is an association relation
	 */
	def static isAssociationRelation(TypedDependency dep) {
		associationRelations.contains(dep.reln.toString)
	}

	/**
	 * @brief Gets a determiner of a node based on the dependencies
	 *
	 * @return May return null if no determiner exists, otherwise the determine in lower case
	 */
	def static getDeterminer(Collection<TypedDependency> dependencies, TreeGraphNode node) {
		val dets = dependencies.filter[it.reln.shortName == "det" && it.gov == node]
		if (dets.empty) null else dets.head.dep.value.toLowerCase
	}

	/**
	 * @brief Checks whether a noun is a plural noun
	 */
	def static isPlural(TreeGraphNode node) {
		node.parent.value.endsWith("S")
	}

	/**
	 * @brief Checks whether a node has a to-many indicating determiner
	 */
	def static hasToManyDeterminer(Collection<TypedDependency> dependencies, TreeGraphNode node) {
		val det = getDeterminer(dependencies, node)
		(det != null) && toManyDeterminers.contains(det)
	}

	/**
	 * @brief Checks whether a relation is a to-many association
	 */
	def static isToManyAssociation(Collection<TypedDependency> dependencies, TreeGraphNode node) {
		node.isPlural || hasToManyDeterminer(dependencies, node)
	}

	/**
	 * @brief Extracts associations from a parse tree
	 */
	def static extractAssociations(Tree tree) {
		val deps = StanfordParser::getTypedDependencies(tree, 5)

		deps.filter[isAssociationRelation].map[dep |
			val child = dep.gov.value.nounNormalForm
			val parent = dep.dep.value.nounNormalForm
			val isMany = isToManyAssociation(deps, dep.gov)

			new ExtractedAssociation(parent, child, isMany)
		]
	}
}
