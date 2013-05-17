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

import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.wizard.WizardPage
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text

/**
 * @brief Wizard page for lips projects
 */
class NewLipsProjectWizardPage extends WizardPage {
	private var Text projectName
	private var ISelection selection

	/**
	 * Constructor for SampleNewWizardPage.
	 *
	 * @param selection The selection that is stored within this object (although
	 * is is never used)
	 */
	new(ISelection selection) {
		super("wizardPage")
		title = "New lips specification project"
		description = "This wizard creates a new lips project."
		this.selection = selection
	}

	/**
	 * @brief Creates the control flow of the wizard page
	 * @see IDialogPage#createControl(Composite)
	 * @param parent The parent composite
	 */
	override createControl(Composite parent) {
		val container = new Composite(parent, SWT::NULL)
		val layout = new GridLayout
		container.layout = layout
		layout.numColumns = 3
		layout.verticalSpacing = 9
		var label = new Label(container, SWT::NULL)
		label.text = "&Project:"

		projectName = new Text(container, SWT::BORDER.bitwiseOr(SWT::SINGLE))
		var gd = new GridData(GridData::FILL_HORIZONTAL)
		projectName.layoutData = gd

		projectName.addModifyListener[ dialogChanged ]

		initialize
		dialogChanged

		projectName.setFocus
		projectName.setSelection(0, getProjectName.length)

		setControl(container)
	}

	/**
	 * @brief Initializes the WizardPage with a default project name
	 */
	def private initialize() {
		projectName.text = "New lips project"
	}

	/**
	 * @brief Performs sanity checks on the input
	 *
	 * The new project's name must be entered and not coincide with an already
	 * existing project or folder.
	 *
	 */
	def private void dialogChanged() {
		val container = ResourcesPlugin::workspace.root.findMember(new Path(getProjectName))

		if (getProjectName.length == 0) {
			updateStatus("Project must be specified")
			return
		}

		if (container != null && container.type.bitwiseAnd(IResource::PROJECT.bitwiseOr(IResource::FOLDER)) != 0) {
			updateStatus("Project already exists!")
			return
		}
		updateStatus(null)
	}
	
	/**
	 * @brief Updates the status message of the WizardPage
	 * @param message The message to display
	 */
	def private updateStatus(String message) {
		errorMessage = message
		pageComplete = message == null
	}

	/**
	 * @brief The entered name of the project
	 * @return The name of the project as a String as entered by the user
	 */
	def getProjectName() {
		projectName.text
	}
}

