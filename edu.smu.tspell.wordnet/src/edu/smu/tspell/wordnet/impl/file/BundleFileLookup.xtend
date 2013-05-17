package edu.smu.tspell.wordnet.impl.file

import java.io.File
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Platform

class BundleFileLookup {
	def static getFile(String name) {
		val bundle = Platform::getBundle("edu.smu.tspell.wordnet")
		val fileURL = bundle.getEntry("dict/" + name)

		new File(FileLocator::resolve(fileURL).toURI)
	}
}