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
package de.agra.lips.editor.selection

import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.ISelectionProvider
import org.eclipse.jface.viewers.IPostSelectionProvider
import org.eclipse.jface.text.ITextSelection
import org.eclipse.jface.text.IDocument
import java.util.ArrayList

class SelectionChangeListener implements ISelectionChangedListener {
    val IDocument document
    val participants = new ArrayList<ISelectionChangeParticipant>

    new(IDocument document) {
        this.document = document
    }

    override selectionChanged(SelectionChangedEvent event) {
        try {
            val selection = event.selection
            if (!selection.empty && selection instanceof ITextSelection) {
                for (p : participants) {
                    p.selectionChanged(selection as ITextSelection)
                }
            }
        } catch (Exception e) {
            println(e.stackTrace)
        }
    }

    def addParticipant(ISelectionChangeParticipant participant) {
        participants += participant
    }

    def install(ISelectionProvider selectionProvider) {
        if (selectionProvider == null) return null

        if (selectionProvider instanceof IPostSelectionProvider) {
            val provider = selectionProvider as IPostSelectionProvider
            provider.addPostSelectionChangedListener(this)
        } else {
            selectionProvider.addSelectionChangedListener(this)
        }
    }

    def uninstall(ISelectionProvider selectionProvider) {
        if (selectionProvider == null) return null

        if (selectionProvider instanceof IPostSelectionProvider) {
            val provider = selectionProvider as IPostSelectionProvider
            provider.removePostSelectionChangedListener(this)
        } else {
            selectionProvider.removeSelectionChangedListener(this)
        }
    }
}
