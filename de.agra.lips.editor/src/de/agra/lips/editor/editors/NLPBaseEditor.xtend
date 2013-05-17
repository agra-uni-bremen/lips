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
package de.agra.lips.editor.editors

import de.agra.lips.editor.generator.ModelGenerator
import de.agra.lips.editor.providers.LipsDocumentProvider
import de.agra.lips.editor.reconciler.IReconcilingParticipant
import de.agra.lips.editor.reconciler.ReconcilingStrategy
import de.agra.lips.editor.selection.SelectionChangeListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.editors.text.TextEditor

class NLPBaseEditor extends TextEditor {
	SelectionChangeListener listener = null
	val ModelGenerator generator

	new () {
		super()
		sourceViewerConfiguration = new Configuration
		documentProvider = LipsDocumentProvider::instance
		generator = new ModelGenerator(sourceViewer)
	}

	override createPartControl(Composite parent) {
		super.createPartControl(parent)
		listener = new SelectionChangeListener(sourceViewer.document)
		listener.install(selectionProvider)

		addToReconciler(generator)
	}

	override getAdapter(Class adapter) {
		super.getAdapter(adapter)
	}

	override dispose() {
		listener.uninstall(selectionProvider)
		super.dispose
	}

	def protected addToReconciler(IReconcilingParticipant participant) {
		val reconciler = sourceViewerConfiguration.getReconciler(sourceViewer).getReconcilingStrategy("") as ReconcilingStrategy
		reconciler.addParticipant(participant)
	}

	def public reconcile() {
		val reconciler = sourceViewerConfiguration.getReconciler(sourceViewer).getReconcilingStrategy("") as ReconcilingStrategy
		reconciler.notifyParticipants
	}

	def getViewer() {
		sourceViewer
	}
}