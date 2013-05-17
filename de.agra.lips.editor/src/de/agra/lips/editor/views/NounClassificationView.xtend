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
package de.agra.lips.editor.views

import de.agra.lips.editor.Activator
import de.agra.lips.editor.util.GuiHelper
import de.agra.nlp.semantical.ClassificationType
import de.agra.nlp.semantical.ClassifiedNoun
import de.agra.nlp.semantical.NounClassification
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.ColumnLabelProvider
import org.eclipse.jface.viewers.ComboBoxViewerCellEditor
import org.eclipse.jface.viewers.EditingSupport
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.TableViewerColumn
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart

/**
 * @brief A view that represents the results of the noun classification
 */
class NounClassificationView extends ViewPart {
	public static val ID = "de.agra.lips.editor.views.nounclassificationview"

	private TableViewer viewer = null

	override createPartControl(Composite parent) {
		createViewer(parent)
	}

	override setFocus() {
		viewer.control.setFocus
	}

	def refresh() {
		viewer.input = toArray
		viewer.refresh
	}

	def void createViewer(Composite parent) {
		viewer = new TableViewer(parent, #[SWT::MULTI, SWT::H_SCROLL, SWT::V_SCROLL, SWT::FULL_SELECTION, SWT::BORDER].reduce[a, b | a.bitwiseOr(b)])
		createColumns

		viewer.table => [
			headerVisible = true
			linesVisible = true
		]

		viewer.contentProvider = ArrayContentProvider::instance
		viewer.input = toArray

		// Make the selection available to other views
		site.selectionProvider = viewer
	
		// Layout the viewer 
		viewer.control.layoutData = new GridData => [
			horizontalSpan = 2
			horizontalAlignment = GridData::FILL
			verticalAlignment = GridData::FILL
			grabExcessHorizontalSpace = true
			grabExcessVerticalSpace = true
		]
	}

	def toArray() {
		Activator::^default.nounDB.asSet.map[it.value].toList
	}

	def void createColumns() {
		val nounColumn = createTableViewerColumn("Noun", 100)
		nounColumn.labelProvider = new NounLabelProvider

		val classifiedColum = createTableViewerColumn("Classification", 100)
		classifiedColum.labelProvider = new ClassifiedLabelProvider

		classifiedColum.editingSupport = new NounClassificationEditingSupport(viewer)

		val classificationTypeColumn = createTableViewerColumn("Decision", 100)
		classificationTypeColumn.labelProvider = new ClassificationTypeLabelProvider
	}

	def private TableViewerColumn createTableViewerColumn(String title, int bound) {
		val viewerColumn = new TableViewerColumn(viewer, SWT::NONE)
		viewerColumn.column => [
			text = title
			width = bound
			resizable = true
			moveable = true
		]
		viewerColumn
	}
}

class NounClassificationEditingSupport extends EditingSupport {
	var TableViewer viewer
	var ComboBoxViewerCellEditor editor

	new(TableViewer viewer) {
		super(viewer)
		this.viewer = viewer

		editor = new ComboBoxViewerCellEditor(viewer.table, SWT::READ_ONLY)
		editor.contentProvider = new ArrayContentProvider
		editor.labelProvider = new LabelProvider

		editor.input = #["Actor", "Class", "Ignore", "Unknown"]
	}

	override protected canEdit(Object element) {
		true
	}

	override protected getCellEditor(Object element) {
		editor
	}

	override protected getValue(Object element) {
		(element as ClassifiedNoun).classification.toString
	}

	override protected setValue(Object element, Object value) {
		if (value != null && value instanceof String) {
			val input = value as String
			val mapping = element as ClassifiedNoun

			mapping.classification = switch(input) {
				case "Actor":   NounClassification::Actor
				case "Class":   NounClassification::Class
				case "Unknown": NounClassification::Unknown
				case "Ignore":  NounClassification::Ignored
				default:        NounClassification::Unknown
			}
			mapping.type = ClassificationType::Manual

			// Store in list of words
			// something in Xtends parsing does not work correctly. a workaround
			// is this seemingly useless activator variable.
			val activator = Activator::^default
			activator.nounDB.put(mapping.noun, mapping)

			// Update the view (just the changed element)
			viewer.update(element, null)

			GuiHelper::NLPEditors.forEach[it.reconcile]
		}
	}
}

class NounLabelProvider extends ColumnLabelProvider {
	override getText(Object element) {
		(element as ClassifiedNoun).noun
	}
	
}

class ClassifiedLabelProvider extends ColumnLabelProvider {
	override getText(Object element) {
		(element as ClassifiedNoun).classification.toString
	}
	
}

class ClassificationTypeLabelProvider extends ColumnLabelProvider {
	override getText(Object element) {
		(element as ClassifiedNoun).type.toString
	}
	
}

