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

import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.wizard.WizardPage
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.dialogs.ContainerSelectionDialog
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.events.SelectionAdapter

/**
 * @brief A wizard page for adding a new lips file
 */
class NewLipsFileWizardPage extends WizardPage {
	Text projectName
	Text fileName
	val ISelection selection
	val initialFileName = "specification.lips"

	/**
	 * Constructor for SampleNewWizardPage
	 *
	 * @param pageName
	 */
	new(ISelection selection) {
		super("wizardPage")
		title = "New lips specification file"
		description = "This wizard creates a new .lips specification file."
		this.selection = selection
	}

	/**
	 * @see IDialogPage#createControl(Composite)
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

		val button = new Button(container, SWT::PUSH)
		button.text = "Browse..."

		button.addSelectionListener(new SelectionAdapterTmp(this))

		label = new Label(container, SWT::NULL)
		label.text = "&File name:"

		fileName = new Text(container, SWT::BORDER.bitwiseOr(SWT::SINGLE))
		gd = new GridData(GridData::FILL_HORIZONTAL)
		fileName.layoutData = gd

		fileName.addModifyListener [ dialogChanged ]

		initialize
		dialogChanged
		
		control = container
		fileName.setFocus
		fileName.setSelection(0, initialFileName.length - 5)
	}

	/**
	 * Tests if the current workbench selection is a suitable container to use.
	 */
	def private initialize() {
		if (selection != null && !selection.empty
				&& selection instanceof IStructuredSelection) {
			val ssel =  selection as IStructuredSelection
			if (ssel.size > 1) {
				return
			}

			val obj = ssel.firstElement
			if (obj instanceof IResource) {
				projectName.text = switch(obj) {
					IContainer:  obj
					default:    (obj as IResource).parent
				}.fullPath.toString
			}
		}
		fileName.text = initialFileName
	}

	/**
	 * Uses the standard container selection dialog to choose the new value for
	 * the container field.
	 */
	def public handleBrowse() {
		val dialog = new ContainerSelectionDialog(
				shell, ResourcesPlugin::workspace.root, false,
				"Select new file container")
		if (dialog.open == ContainerSelectionDialog::OK) {
			val result = dialog.result
			if (result.size == 1) {
				projectName.text = (result.get(0) as Path).toString
			}
		}
	}

	/**
	 * Ensures that both text fields are set.
	 */
	def private void dialogChanged() {
		val pName = projectName.text
		val container = ResourcesPlugin::workspace.root.findMember(new Path(pName))
		val fName = fileName.text

		if (pName.length == 0) {
			updateStatus("Project must be specified")
			return
		}

		if (container == null || container.type.bitwiseAnd(IResource::PROJECT.bitwiseOr(IResource::FOLDER)) == 0) {
			updateStatus("Project must exist")
			return
		}

		if (!container.accessible) {
			updateStatus("Project must be writable")
			return
		}

		if (fName.length== 0) {
			updateStatus("File name must be specified")
			return
		}

		if (fName.replace('\\', '/').indexOf('/', 1) > 0) {
			updateStatus("File name must be valid")
			return
		}

		val dotLoc = fName.lastIndexOf('.')
		if (dotLoc != -1) {
			val ext = fName.substring(dotLoc + 1)
			if (ext.equalsIgnoreCase("lips") == false) {
				updateStatus("File extension must be \"lips\"")
				return
			}
		}
		updateStatus(null)
	}

	def private updateStatus(String message) {
		errorMessage = message
		pageComplete = message == null
	}

	def getProjectName() {
		projectName.text
	}

	def String getFileName() {
		fileName.text
	}
}

class SelectionAdapterTmp extends SelectionAdapter {
	val NewLipsFileWizardPage page
	new(NewLipsFileWizardPage p) {
		page = p
	}

	override widgetSelected(SelectionEvent e) {
		page.handleBrowse
	}
}
