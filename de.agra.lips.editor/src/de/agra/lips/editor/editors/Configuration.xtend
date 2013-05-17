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

import de.agra.lips.editor.hyperlinks.ClassLinkDetector
import de.agra.lips.editor.reconciler.ReconcilingStrategy
import java.util.HashMap
import org.eclipse.jface.text.reconciler.IReconciler
import org.eclipse.jface.text.reconciler.MonoReconciler
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.ui.editors.text.TextSourceViewerConfiguration

class Configuration extends TextSourceViewerConfiguration {
	val reconcilers = new HashMap<ISourceViewer, IReconciler>()

	override getReconciler(ISourceViewer sourceViewer) {
		if (!reconcilers.containsKey(sourceViewer)) {
			val reconciler = new MonoReconciler(new ReconcilingStrategy, true)
			reconciler.install(sourceViewer)
			reconcilers.put(sourceViewer, reconciler)
		}
		reconcilers.get(sourceViewer)
	}

	override getHyperlinkDetectors(ISourceViewer sourceViewer) {
		#[new ClassLinkDetector]
	}
	
}
