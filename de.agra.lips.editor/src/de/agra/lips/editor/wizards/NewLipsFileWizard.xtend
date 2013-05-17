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
package de.agra.lips.editor.wizards

import java.io.ByteArrayInputStream
import java.io.IOException
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Status
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.wizard.Wizard
import org.eclipse.ui.INewWizard
import org.eclipse.ui.IWorkbench
import org.eclipse.ui.PartInitException
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.ide.IDE

/**
 * @brief A wizard to add a new file
 */
class NewLipsFileWizard extends Wizard implements INewWizard {
	NewLipsFileWizardPage page
	ISelection selection
	val initialText = "This file specifies a system."

	/**
	 * Adding the page to the wizard
	 */
	override addPages() {
		page = new NewLipsFileWizardPage(selection)
		addPage(page)
	}

	/**
	 * This method is called when 'Finish' button is pressed in
	 * the wizard. We will create an operation and run it
	 * using wizard as execution context.
	 */
	override performFinish() {
		val root = ResourcesPlugin::workspace.root
		val project = page.projectName
		val resource = root.findMember(new Path(project))
		if (!resource.exists() || !(resource instanceof IContainer)) {
			throwCoreException('''Container "«project»" does not exist.''')
		}
		val container =  resource as IContainer
		val file = container.getFile(new Path(page.fileName))
		try {
			val stream = new ByteArrayInputStream(initialText.bytes)
			if (file.exists) {
				file.setContents(stream, true, true, null)
			} else {
				file.create(stream, true, null)
			}
			stream.close
		} catch (IOException e) {
			println('''Unhandled IOException: «e»''')
			return false
		}

		val page = PlatformUI::workbench.activeWorkbenchWindow.activePage
		try {
			IDE::openEditor(page, file, true)
		} catch (PartInitException e) {
			return false
		}

		// refreshes the eclipse workspace. Only needed if the file was created
		// using the File class und not the IFile class
		//
		// Therefore it is not used right now
		// container.refreshLocal(IResource::DEPTH_INFINITE, null)
		true
	}

	/**
	 * @brief Internal method for throwing exceptions
	 *
	 * This function is a wrapper for the CoreException
	 *
	 * @param message The exception message that gets wrapped in a CoreException
	 */
	def private throwCoreException(String message) throws CoreException {
		val status = new Status(IStatus::ERROR, "de.agra.lips.editor",
		                        IStatus::OK, message, null)
		throw new CoreException(status)
	}

	/**
	 * We will accept the selection in the workbench to see if
	 * we can initialize from it.
	 *
	 * @note This comment is copied from the eclipse wizard example
	 *
	 * @see IWorkbenchWizard#init(IWorkbench, IStructuredSelection)
	 */
	override init(IWorkbench workbench, IStructuredSelection selection) {
		this.selection = selection
	}
	
}
