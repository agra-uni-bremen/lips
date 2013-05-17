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

import java.util.List
import java.util.ArrayList
import edu.stanford.nlp.trees.TypedDependency


/**
 * @brief Models a typed dependency between two words of a sentence
 */
class SimpleDep implements Comparable<SimpleDep> {
	@Property String dependent

	/**
	 * @brief The position of the word within the parsed sentence
	 */
	@Property int dependentIndex

	/**
	 * @brief The position of the referenced word within the parsed sentence
	 */
	@Property int governorIndex

	/**
	 * @brief The kind of the dependency
	 */
	@Property String relation

	/**
	 * @brief The word that this.word depends on
	 * 
	 * This field is actually redundant as the whole dependency
	 * this.word refers to is stored in refDep
	 */
	@Property String governor

	/**
	 * @brief The typed dependency that is owned by the word this.word
	 * is referencing
	 */
	@Property SimpleDep refDep

	/**
	 * @brief List of Words this.word governs(?)
	 */
	@Property List<SimpleDep> governedDependencies

	/**
	 *  @brief The part-of-speech (POS) of the dependent
	 */
	 @Property String pos

	/**
	 * @brief Creates a new typed dependency between two words
	 *
	 * @warning This constructor does not fill every field. refWord and
	 * refGov are filled later by the fillDeps function which must be called
	 * after the whole ParZu output has been processed.
	 *
	 * @param dependent The dependent
	 * @param dep_index The index of the dependent in the sentence
	 * @param gov_index The index of the governor
	 * @param depType The type of the dependency
	 * @param pos The part of speech of the dependent
	 */
	new(String dependent, int dep_index, int gov_index, String depType, String pos) {
		this.dependent=dependent
		this.dependentIndex=dep_index
		this.governorIndex=gov_index
		this.relation=depType
		this.pos=pos
		governedDependencies=new ArrayList<SimpleDep>()
	}

	/**
	 * @brief Converts a TypedDependency to a simple SimpleDep
	 * 
	 * @warning Note that this neither sets the word index of the dependent nor fills
	 * the list of governed dependencies. So do not expect a List of SimpleDeps
	 * to behave as one created by parsing the ParZu output!
	 * 
	 * @param dep The TypedDependency that will be converted to 
	 */
	new(TypedDependency dep) {
		this.relation=dep.reln.toString

		var tmpTuple=dep.dep.label.toString.split("-")
		this.dependent=tmpTuple.get(0)
		this.dependentIndex=Integer::parseInt(tmpTuple.get(1))

		tmpTuple=dep.gov.label.toString.split("-")
		this.governor=tmpTuple.get(0)
		this.governorIndex=Integer::parseInt(tmpTuple.get(1))
	}

	/**
	 * @brief Returns a String of the form relation(governor-index,dependent-index)
	 */
	override toString() {
		'''«relation»(«governor»-«governorIndex»,«dependent»-«dependentIndex»)'''
	}

	/**
	 * @brief Compares two simple dependencies with respect to the appearance in
	 * the sentence
	 *
	 * @returns 0 if the dependencies are the same, 1 if this object appears earlier
	 * in the sentence and -1 otherwise
	 */
	override compareTo(SimpleDep depToCompareTo) {
		if (this == depToCompareTo) {
			0
		} else if (this.dependentIndex < depToCompareTo.dependentIndex) {
			1
		} else {
			-1
		}
	}
	
}
