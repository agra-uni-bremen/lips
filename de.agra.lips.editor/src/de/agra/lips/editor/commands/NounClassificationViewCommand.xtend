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
package de.agra.lips.editor.commands

import de.agra.lips.editor.Activator
import de.agra.lips.editor.util.GuiHelper
import de.agra.lips.editor.views.NounClassificationView
import de.agra.nlp.semantical.ClassifiedNoun
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.FileDialog
import org.eclipse.ui.PlatformUI

class NounClassificationViewCommand extends AbstractHandler {
	override execute(ExecutionEvent event) throws ExecutionException {
		val cmd = event.getParameter("de.agra.lips.editor.commands.parameters.classification.cmd")
		val view = GuiHelper::findView("de.agra.lips.editor.views.nounclassificationview") as NounClassificationView

		if (view != null) {
			val nounDB = Activator::^default.nounDB
			switch (cmd) {
				case "selection": {
					val selection = view.site.selectionProvider.selection as IStructuredSelection
					for (noun : selection.iterator.toSet.map[(it as ClassifiedNoun).noun]) {
						nounDB.remove(noun)
					}
				}
				case "clear":
					nounDB.clear
				case "load": {
					val dialog = new FileDialog(PlatformUI::workbench.activeWorkbenchWindow.shell, SWT::OPEN)
					dialog.filterPath = nounDB.dbPath
					nounDB.load(dialog.open)
				}
				case "save": {
					val dialog = new FileDialog(PlatformUI::workbench.activeWorkbenchWindow.shell, SWT::SAVE)
					dialog.filterPath = nounDB.dbPath
					dialog.fileName = "cn.db"
					nounDB.store(dialog.open)
				}
				default:
					println('''Wrong cmd for NounClassificationViewCommand specified: «cmd»''')
			}
			view.refresh
		}
		null
	}
}
