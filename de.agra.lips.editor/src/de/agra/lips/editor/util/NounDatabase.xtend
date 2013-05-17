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
package de.agra.lips.editor.util

import java.util.HashMap
import de.agra.nlp.semantical.ClassifiedNoun
import java.io.ObjectInputStream
import java.io.FileInputStream
import java.io.ObjectOutputStream
import java.io.FileOutputStream

class NounDatabase {
	val nouns = new HashMap<String, ClassifiedNoun>
	var String dbPath

	def getDbPath() { dbPath }

	def getNounsMap() { nouns }

	def remove(String key) {
		nouns.remove(key)
	}

	def clear() { nouns.clear }

	def asSet() {
		nouns.entrySet
	}

	def put(String word, ClassifiedNoun cls) {
		nouns.put(word, cls)
	}

	def store() {
		store(this.dbPath)
	}

	def store(String dbPath) {
		try {
			val out = new ObjectOutputStream(new FileOutputStream(dbPath))
			out.writeObject(nouns)
		} catch (Exception e) {
			println('''Could not save noun database to "«dbPath»"''')
			e.printStackTrace
		}
	}

	def load(String dbPath) {
		try {
			val in = new ObjectInputStream(new FileInputStream(dbPath))
			val classifiedNouns = in.readObject as HashMap<String, ClassifiedNoun>
			nouns.clear
			nouns.putAll(classifiedNouns)
			this.dbPath = dbPath
		} catch (Exception e) {
			println('''Could not load database from "«dbPath»"''')
			e.printStackTrace
		}
	}
}
