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
 package de.agra.lips.editor

import de.agra.lips.editor.util.NounDatabase
import de.agra.nlp.StanfordParser
import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import java.util.logging.LogManager
import java.util.logging.Logger
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.osgi.framework.BundleContext

class Activator extends AbstractUIPlugin {
	static var Activator plugin = null
	static val logger = Logger::getLogger(typeof(Activator).name)

	@Property val parser = new StanfordParser
	@Property val nounDB = new NounDatabase

	/**
	 * @brief Starts the activator, loads noun database and listens
	 *        to changes to the WordNet path
	 *
	 * @param context bundle context in which the plugin is started
	 */
	override start(BundleContext context) throws Exception {
		super.start(context)

		plugin=this

		loadJULConfig
		logger.finer("Starting eclipse/lips")

		loadNoundDB
	}
	
	def loadNoundDB() {
		logger.fine('''Load noundb from "«nounDBPath»"''')
		nounDB.load(nounDBPath)
		logger.finer('''Loaded «nounDB.asSet.size» noun(s)''')
	}

	def loadJULConfig() {
		val stdConfig='''
		.level= ALL
		handlers= java.util.logging.ConsoleHandler
		java.util.logging.ConsoleHandler.level=ALL
		java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
		java.util.logging.SimpleFormatter.format=%5$s [%2$s|%4$s]%n
		'''

		println('''JUL Configpath from PreferenceStore: «preferenceStore.getString("de.agra.lips.julconfigpath")»''')

		var configPath = preferenceStore.getString("de.agra.lips.julconfigpath")

		if (configPath == null) {
			val workspacePath = ResourcesPlugin::workspace.root.location.toString
			val JULFile = new File(workspacePath, "jul.config")
			System::err.println('''No JUL config file specified. Creating one in "«JULFile.path»"''')
			configPath = JULFile.path
		}
		
		val configFile = new File(configPath)
		if (!configFile.exists) {
			val outFile = new BufferedWriter(new FileWriter(configFile))
			System::err.println('''File  "«configFile.path»" does not exist. Creating standard configuration.''')
			outFile.write(stdConfig)
			outFile.flush
			outFile.close
		}
		
		System::setProperty("java.util.logging.config.file", configFile.path)
		
		try {
			println('''Trying to load configuration from "«System::getProperty("java.util.logging.config.file")»"''')
			LogManager::logManager.readConfiguration
		} catch ( Exception e ) {
			System::err.println("Could not load JUL configuation")
			e.printStackTrace
		}
	}

	/**
	 * @brief Returns the path to the noun database
	 */
	def private getNounDBPath() {
		preferenceStore.getString("de.agra.lips.noundbpath")
	}

	/**
	 * @brief Stops the activator, and stores the noun database
	 *
	 * @param context bundle context in which the plugin is started
	 */
	override stop(BundleContext context) throws Exception {
		nounDB.store(nounDBPath)
		logger.fine('''Stored «nounDB.asSet.size» noun(s) at "«nounDBPath»"''')

		plugin = null
		logger.finer("Stopping eclipse")
	}

	/**
	 * @brief Returns a singleton instance to the activator
	 */
	def static getDefault() {
		plugin
	}
}