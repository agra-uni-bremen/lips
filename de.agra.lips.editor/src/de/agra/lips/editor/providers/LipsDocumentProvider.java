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
package de.agra.lips.editor.providers;

import java.util.Iterator;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.IDocument;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.editors.text.FileDocumentProvider;
import org.eclipse.ui.texteditor.DocumentProviderRegistry;

/**
 * @brief A customized file document provider for the editor
 *
 * We are mainly using this class to implement a mapping from IDocument instances
 * to IFile instances.
 */
public class LipsDocumentProvider extends FileDocumentProvider {
	static String EXTENSION = "lips";
	static LipsDocumentProvider theInstance = null;

	/**
	 * @brief Implements the singleton pattern on LipsDocumentProvider
	 *
	 * @return A singleton instance to LipsDocumentProvider
	 */
	public static LipsDocumentProvider instance() {
		if (theInstance == null) {
			final DocumentProviderRegistry dr = DocumentProviderRegistry.getDefault();
			theInstance = (LipsDocumentProvider) dr.getDocumentProvider(EXTENSION);
			if (theInstance == null) {
				throw new IllegalStateException("No document provider found for " + EXTENSION);
			}
		}
		return theInstance;
	}

	/**
	 * @brief Returns the IFile instance to a given IDocument instance
	 *
	 * @param document The document instance
	 * @return The file instance
	 */
	public IFile getFile(IDocument document) {
		IFile file = null;

		@SuppressWarnings("unchecked")
		final Iterator<Object> iterator = getConnectedElements();
		while (iterator.hasNext() && file == null) {
			final Object elem = iterator.next();
			if (elem instanceof IFileEditorInput) {
				ElementInfo info = getElementInfo(elem);
				if (info.fDocument == document) {
					file = ((IFileEditorInput) elem).getFile();
				}
			}
		}
		return file;
	}
}