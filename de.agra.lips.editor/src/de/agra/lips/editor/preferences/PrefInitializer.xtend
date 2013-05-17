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

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer
import de.agra.lips.editor.Activator
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import java.util.logging.Logger

/**
 * @brief Class for initializing the preferences with default values
 */
class PrefInitializer extends AbstractPreferenceInitializer {
	static val logger = Logger::getLogger(typeof(PrefInitializer).name)

	/**
	 * @brief Sets the default values for the preferences
	 */
	override initializeDefaultPreferences() {
		logger.finest("PrefInitializer started")
		val store = Activator::^default.preferenceStore
		val workspacePath = ResourcesPlugin::workspace.root.location.toString
		val dbFile = new File(workspacePath, "nouns.db")
		store.setDefault("de.agra.lips.noundbpath", dbFile.path)

		val JULFile = new File(workspacePath, "jul.config")
		store.setDefault("de.agra.lips.julconfigpath", JULFile.path)
	}
}
