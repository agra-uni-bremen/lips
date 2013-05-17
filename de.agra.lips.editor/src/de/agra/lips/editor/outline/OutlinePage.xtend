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

import de.agra.lips.editor.reconciler.IReconcilingParticipant
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.views.contentoutline.ContentOutlinePage

/**
 * @brief An outline page for lips documents
 */
class OutlinePage extends ContentOutlinePage implements IReconcilingParticipant {
	var IDocument document = null

	/**
	 * @brief Creates the control
	 */
	override createControl(Composite parent) {
		super.createControl(parent)
		treeViewer.contentProvider = new ContentProvider
		treeViewer.labelProvider = new LabelProvider
		treeViewer.addSelectionChangedListener(this)
	}

	/**
	 * @brief Updates the document in the tree
	 */
	def setDocument(IDocument document) {
		this.document = document
		if (treeViewer != null && !treeViewer.control.disposed) {
			treeViewer.setInput(document.get.split("\n"))
		}
		
	}

	/**
	 * @brief Reconciles the outline page
	 */
	override reconcile(IDocument document) {
		setDocument(document)
	}
}
