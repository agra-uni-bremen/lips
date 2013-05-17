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

import de.agra.lips.editor.Activator
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.NounClassificationView
import de.agra.nlp.semantical.ClassificationType
import de.agra.nlp.semantical.ClassifiedNoun
import de.agra.nlp.semantical.NounClassification
import de.agra.nlp.semantical.Word
import java.util.logging.Logger
import org.eclipse.core.resources.IMarker
import org.eclipse.ui.IMarkerResolution

/**
 * @brief Quick fix for the classification of nouns
 *
 * @note This class does not provide any quick assists!
 */
class QuickFix implements IMarkerResolution {
	val String label
	val NounClassification classification
	val Word noun
	static val logger = Logger::getLogger(typeof(QuickFix).name)

	/**
	 * @brief Constructor simply setting the data fields
	 * @param l The label text of the quick fix
	 * @param n The noun that could not be classified
	 * @param c The proposed classification for the noun
	 */
	new(String l, Word w, NounClassification c) {
		label = l
		noun = w
		classification = c
	}

	/**
	 * @brief Performs the quick fix
	 *
	 * The stored solution (noun -> classification) is stored in the Activator
	 */
	override run(IMarker marker) {
		val classifiedNouns = Activator::^default.nounDB.nounsMap
		val newlyClassifiedNoun = new ClassifiedNoun(noun, classification, ClassificationType::Manual)
		classifiedNouns.put(noun.word, newlyClassifiedNoun)

		logger.finest('''Applied QuickFix: «newlyClassifiedNoun» stored in nounDB''')

		// now the view has to be updated
		val nounView = GuiHelper::findView(NounClassificationView::ID) as NounClassificationView
		nounView?.refresh

		marker.delete

		// as classifying a word removes all instances of the problem, we reconcile
		// the documents of all open NLP editors
		GuiHelper::NLPEditors.forEach[it.reconcile]
	}

	/**
	 * @brief Returns the QuickFix label
	 *
	 * @return The label to display in the quick fix/problem view
	 */
	override getLabel() {
		label
	}
}
