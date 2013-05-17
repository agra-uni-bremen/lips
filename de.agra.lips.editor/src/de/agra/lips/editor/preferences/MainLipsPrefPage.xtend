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
package de.agra.lips.editor.preferences

import de.agra.lips.editor.Activator
import org.eclipse.jface.preference.FieldEditorPreferencePage
import org.eclipse.jface.preference.FileFieldEditor
import org.eclipse.ui.IWorkbench
import org.eclipse.ui.IWorkbenchPreferencePage

/**
 * @brief Main preference page
 */
class MainLipsPrefPage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
	
	
	override createFieldEditors() {
		addField(new FileFieldEditor("de.agra.lips.noundbpath", "Noun database path", fieldEditorParent))
		//addField(new FileFieldEditor("de.agra.lips.julconfigpath", "JUL configuration file path", fieldEditorParent))
	}


	override init(IWorkbench workbench) {
		preferenceStore = Activator::^default.preferenceStore
		description = "Lips configuration"
	}
}
