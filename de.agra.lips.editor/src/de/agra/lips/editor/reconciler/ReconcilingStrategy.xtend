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
package de.agra.lips.editor.reconciler

import org.eclipse.jface.text.reconciler.IReconcilingStrategy
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.IRegion
import org.eclipse.jface.text.reconciler.DirtyRegion
import java.util.ArrayList
import org.eclipse.swt.widgets.Display

class ReconcilingStrategy implements IReconcilingStrategy {
	val participants = new ArrayList<IReconcilingParticipant>
	var IDocument document = null

	override reconcile(IRegion partition) {
		notifyParticipants
	}

	override reconcile(DirtyRegion dirtyRegion, IRegion subRegion) {
		notifyParticipants
	}

	override setDocument(IDocument document) {
		this.document = document
	}

	def addParticipant(IReconcilingParticipant participant) {
		participants += participant
	}

	def getParticipants() {
		participants
	}

	/**
	 * @brief This does the actual work in an asynchronous thread.
	 */
	def notifyParticipants() {
		for (p : participants) {
			Display::^default.asyncExec([|p.reconcile(document)])
		}
	}
}
