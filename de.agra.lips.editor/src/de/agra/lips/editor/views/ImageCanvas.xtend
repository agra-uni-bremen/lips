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

import java.awt.geom.AffineTransform
import org.eclipse.swt.SWT
import org.eclipse.swt.events.ControlEvent
import org.eclipse.swt.events.ControlListener
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.events.SelectionListener
import org.eclipse.swt.graphics.GC
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.widgets.Canvas
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.ScrollBar
import org.eclipse.swt.graphics.ImageLoader
import org.eclipse.swt.widgets.FileDialog

/**
 * @brief This canvas is used to display phrase structure tree and dependency graph
 */
class ImageCanvas extends Canvas implements ControlListener, SelectionListener {
	val ZOOMIN_RATE = 1.1f
	val ZOOMOUT_RATE = 0.9f
	Image sourceImage = null
	Image screenImage = null
	private val stdFilename = "parsed_structure.png"
	AffineTransform transform = new AffineTransform
	val ImageLoader loader = new ImageLoader

	new(Composite parent) {
		this(parent, SWT::NULL)
	}

	new(Composite parent, int style) {
		super(parent, #[style, SWT::BORDER, SWT::V_SCROLL, SWT::H_SCROLL, SWT::NO_BACKGROUND].reduce[a, b | a.bitwiseOr(b)])

		addControlListener(this)
		addPaintListener([e | paint(e.gc)])

		initScrollBars
	}

	override dispose() {
		super.dispose
	}

	def private paint(GC gc) {
		val clientRect = clientArea
		if (sourceImage != null) {
			var imageRect = SWT2Dutil::inverseTransformRect(transform, clientRect)
			val gap = 2
			imageRect.x = imageRect.x - gap
			imageRect.y = imageRect.y - gap
			imageRect.width = imageRect.width + (2 * gap)
			imageRect.height = imageRect.height + (2 * gap)

			val imageBound = sourceImage.bounds
			imageRect = imageRect.intersection(imageBound)
			val destRect = SWT2Dutil::transformRect(transform, imageRect)

			screenImage?.dispose
			screenImage = new Image(display, clientRect.width, clientRect.height)
			val newGC = new GC(screenImage)
			newGC.clipping = clientRect
			newGC.drawImage(
				sourceImage,
				imageRect.x,
				imageRect.y,
				imageRect.width,
				imageRect.height,
				destRect.x,
				destRect.y,
				destRect.width,
				destRect.height)
			newGC.dispose

			gc.drawImage(screenImage, 0, 0)
		} else {
			gc.clipping = clientRect
			gc.fillRectangle(clientRect)
			initScrollBars
		}
	}

	def private initScrollBars() {
		horizontalBar.enabled = false
		horizontalBar.addSelectionListener(this)

		verticalBar.enabled = false
		verticalBar.addSelectionListener(this)
	}

	def getSourceImage() {
		sourceImage
	}

	def private syncScrollBars() {
		if (sourceImage == null) {
			redraw
			return
		}

		var af = transform
		val sx = af.scaleX
		val sy = af.scaleY
		var tx = af.translateX
		var ty = af.translateY
		if (tx > 0) tx = 0
		if (ty > 0) ty = 0

		horizontalBar.increment = (clientArea.width / 100) as int
		horizontalBar.pageIncrement = clientArea.width
		val imageBound = sourceImage.getBounds();
		val cw = clientArea.width
		val ch = clientArea.height
		if (imageBound.width * sx > cw) { /* image is wider than client area */
			horizontalBar.maximum = (imageBound.width * sx) as int
			horizontalBar.enabled = true
			if ((-tx as int) > horizontalBar.maximum - cw) {
				tx = -horizontalBar.maximum + cw
			}
		} else { /* image is narrower than client area */
			horizontalBar.enabled = false
			tx = (cw - imageBound.width * sx) / 2 //center if too small.
		}
		horizontalBar.selection = -tx as int
		horizontalBar.thumb = clientArea.width as int

		verticalBar.increment = (clientArea.height / 100) as int
		verticalBar.pageIncrement = clientArea.height as int
		if (imageBound.height * sy > ch) { /* image is higher than client area */
			verticalBar.maximum = (imageBound.height * sy) as int
			verticalBar.enabled = true
			if ((-ty as int) > verticalBar.maximum - ch) {
				ty = -verticalBar.maximum + ch
			}
		} else { /* image is less higher than client area */
			verticalBar.enabled = false
			ty = (ch - imageBound.height * sy) / 2 //center if too small.
		}
		verticalBar.selection = -ty as int
		verticalBar.thumb = clientArea.height as int

		/* update transform. */
		af = AffineTransform::getScaleInstance(sx, sy)
		af.preConcatenate(AffineTransform::getTranslateInstance(tx, ty))
		transform = af

		redraw
	}

	/**
	 * @brief Checks if there is an image displayed
	 */
	def isImageDisplayed() {
		return sourceImage != null && !sourceImage.disposed
	}

	/**
	 * @brief Loads and displays an image
	 *
	 * If there already is an image displayed, the old one is disposed and replaced
	 * by the new one.
	 *
	 * @param filename Path to the image that should be displayed
	 */
	def loadImage(String filename) {
		if (isImageDisplayed) {
			sourceImage.dispose
			sourceImage = null
		}
		sourceImage = new Image(display, filename)

		// store the image in a loader so that it can be saved later on.
		loader.load(filename)
		showOriginal
		sourceImage
	}

	/**
	 * @brief Saves the image displayed by the canvas to a file
	 */
	def public saveImage() {
		saveImage("parsed_structure.png")
	}

	/**
	 * @brief Saves the image displayed by the canvas to a file
	 * @param filename The path to the file to store the image to
	 */
	def public saveImage(String filename) {
		if (sourceImage != null) {
			val dialog = new FileDialog(shell, SWT::SAVE)
			dialog.setFileName(filename ?: stdFilename)
			val path = dialog.open

			loader.save(path, SWT::IMAGE_PNG)
		}
	}

	def fitCanvas() {
		if (sourceImage == null) return

		val imageBound = sourceImage.bounds
		val destRect = clientArea
		val sx = destRect.width as double / imageBound.width as double
		val sy = destRect.height as double / imageBound.height as double
		val s = Math::min(sx, sy)
		val dx = 0.5 * destRect.width
		val dy = 0.5 * destRect.height
		centerZoom(dx, dy, s, new AffineTransform)
	}

	def showOriginal() {
		if (sourceImage == null) return

		transform = new AffineTransform
		syncScrollBars
	}

	def centerZoom(double dx, double dy, double scale, AffineTransform af) {
		af.preConcatenate(AffineTransform::getTranslateInstance(-dx, -dy))
		af.preConcatenate(AffineTransform::getScaleInstance(scale, scale))
		af.preConcatenate(AffineTransform::getTranslateInstance(dx, dy))
		transform = af
		syncScrollBars
	}

	def zoomIn() {
		zoom(ZOOMIN_RATE)
	}

	def zoomOut() {
		zoom(ZOOMOUT_RATE)
	}

	def zoom(float rate) {
		if (sourceImage == null) return
		val rect = clientArea
		val w = rect.width
		val h = rect.height
		val dx = w as double / 2
		val dy = h as double / 2
		centerZoom(dx, dy, rate, transform)
	}

	override controlMoved(ControlEvent e) {
	}

	override controlResized(ControlEvent e) {
		syncScrollBars
	}

	override widgetDefaultSelected(SelectionEvent e) {
	}

	override void widgetSelected(SelectionEvent e) {
		if (sourceImage != null) {
			val select = -(e.widget as ScrollBar).selection
			if (e.widget == horizontalBar) {
				val tx = transform.translateX
				transform.preConcatenate(AffineTransform::getTranslateInstance(select - tx, 0))
			} else if (e.widget == verticalBar) {
				val ty = transform.translateY
				transform.preConcatenate(AffineTransform::getTranslateInstance(0, select - ty))
			}
			syncScrollBars
		}
	}
}
