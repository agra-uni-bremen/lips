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

import java.util.Collections
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.Viewer

/**
 * @brief Provides the content for the NLP editor outline
 */
class ContentProvider  implements ITreeContentProvider {
	val PST = "Phrase Structure Tree"
	val TYPEDDEPS = "Typed Dependencies"

	/**
	 * @brief Returns the children elements
	 */
	override getChildren(Object parentElement) {
		switch (parentElement) {
			String[]:        parentElement.filter[!it.trim.empty]
			String:          #[PST, TYPEDDEPS].map[new OutlineCategory(it, parentElement)]
			OutlineTree:     parentElement.children
			OutlineCategory: parentElement.categoryChildren
			default:         Collections::EMPTY_LIST
		}
	}

	/**
	 * @brief Elements are the children
	 */
	override getElements(Object inputElement) {
		getChildren(inputElement)
	}

	/**
	 * @brief Parent access is not implemented
	 */
	override getParent(Object element) {
		null
	}

	/**
	 * @brief Checks whether element provides children
	 */
	override hasChildren(Object element) {
		switch (element) {
			String[]:        true
			String:          !element.empty
			OutlineTree:     !element.empty
			OutlineCategory: !element.empty
			default:         false
		}
	}

	override dispose() {
	}

	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}

	/**
	 * @brief Returns the children for an outline category
	 */
	private def getCategoryChildren(OutlineCategory category) {
		if (category.name.equals(PST)) #[category.tree] else category.simpleDependencies
	}

	/**
	 * @brief Checks whether an outline category provides children
	 */
	private def isEmpty(OutlineCategory category) {
		if (category.name.equals(PST)) category.tree.empty else category.simpleDependencies.empty
	}
}
