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
package de.agra.lips.editor.markers

import de.agra.nlp.semantical.NounClassification
import de.agra.nlp.util.WordNetLexicographer
import edu.smu.tspell.wordnet.Synset
import edu.smu.tspell.wordnet.SynsetType
import edu.smu.tspell.wordnet.WordNetDatabase
import edu.smu.tspell.wordnet.impl.file.ReferenceSynset
import org.eclipse.core.resources.IMarker
import org.eclipse.ui.IMarkerResolutionGenerator
import org.eclipse.ui.IMarkerResolutionGenerator2
import de.agra.nlp.semantical.Word

/**
 * @brief Provides QuickFixes for unclassified nouns
 * */
class NLPQuickFixMarkerGenerator implements IMarkerResolutionGenerator, IMarkerResolutionGenerator2 {
	/**
	 * @brief Returns the quick fixes for unclassified nouns
	 *
	 * The function is called for markers of the type
	 * de.agra.lips.editor.markers.nounclassificationmarker, i.e. unclassified
	 * nouns 
	 *
	 * @note Note that the actual fixes are not implemented in this class but
	 * in the objects returned by the getResolutions function
	 *
	 * @return ArrayList of QuickFixes providing a choice of the noun type
	 */
	override getResolutions(IMarker marker) {
		val wordnet = WordNetDatabase::fileInstance
		val noun = marker.attributes.get("unclassifiedNoun") as Word
		val synsets = wordnet.getSynsets(noun.word, SynsetType::NOUN)

		#[new QuickFix("Choose: \"Class\"", noun, NounClassification::Class),
		  new QuickFix("Choose: \"Actor\"", noun, NounClassification::Actor)]
			+ synsets.map[it.toQuickFix(noun)].filter[it != null]
	}

	/**
	 * @brief Returns whether there are any resolutions for the specified marker
	 *
	 * This should speed up the GUI as there is no need to actually query the
	 * WordNet database.
	 *
	 * As we always add at least two resolutions, always returning true is
	 * correct.
	 *
	 * @return true
	 */
	override hasResolutions(IMarker marker) {
		true
	}

	/**
	 * @brief Creates a quick fix for a synset, might return null
	 *
	 * @param s Synset
	 * @param noun The initial noun to the synset
	 *
	 * @return Quick fix, if noun classification is not unknown
	 */
	private def toQuickFix(Synset s, Word noun) {
		val tagCount = s.getTagCount(s.wordForms.head)
		val rs = s as ReferenceSynset
		val classification = WordNetLexicographer::mapToClassOrActor(rs.lexicalFileNumber)
		val spec = WordNetLexicographer::toReadableString(rs.lexicalFileNumber)
		val shortDescription =
			'''Choose: "«classification»" <«spec»> («tagCount») «s.wordForms.map[it.toString].join(", ")» -- «s.definition»'''
		if (classification != NounClassification::Unknown) {
			new QuickFix(shortDescription, noun, classification)
		} else {
			null
		}
	}
}

