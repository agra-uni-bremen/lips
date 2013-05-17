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

import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.wizard.Wizard
import org.eclipse.ui.INewWizard
import org.eclipse.ui.IWorkbench

/**
 * @brief Wizard for new lips projects
 */
class NewLipsProjectWizard extends Wizard implements INewWizard {
	NewLipsProjectWizardPage page
	ISelection selection
	
	/**
	 * Adding the page to the wizard.
	 */
	override addPages() {
		page = new NewLipsProjectWizardPage(selection)
		addPage(page)
	}

	/**
	 * This method is called when 'Finish' button is pressed in
	 * the wizard. We will create an operation and run it
	 * using wizard as execution context.
	 */
	override performFinish() {
		val root = ResourcesPlugin::workspace.root

		val projectName = page.projectName

		if (projectName.length > 0) {
			val progressMonitor = new NullProgressMonitor
			val project = root.getProject(projectName)
			project.create(progressMonitor)
			project.open(progressMonitor)
		}

		// refreshes the eclipse workspace. Only needed if the file was created
		// using the File class and not the IFile class
		//
		// Therefore it is not used right now
		// container.refreshLocal(IResource::DEPTH_INFINITE, null)
		true
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
