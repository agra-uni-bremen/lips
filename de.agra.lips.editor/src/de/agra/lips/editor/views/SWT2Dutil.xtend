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
import java.awt.geom.Point2D
import org.eclipse.swt.graphics.Point
import org.eclipse.swt.graphics.Rectangle

/**
 * @brief A utility class for the canvas view
 */
class SWT2Dutil {
    /**
     * Given an arbitrary rectangle, get the rectangle with the given transform.
     * The result rectangle is positive width and positive height.
     * @param af AffineTransform
     * @param src source rectangle
     * @return rectangle after transform with positive width and height
     */
    def static transformRect(AffineTransform af, Rectangle src) {
        var dest = new Rectangle(0, 0, 0, 0)
        val src_new = absRect(src)
        var p1 = new Point(src_new.x, src_new.y)
        p1 = transformPoint(af, p1)
        dest.x = p1.x; dest.y = p1.y
        dest.width = (src_new.width * af.scaleX) as int
        dest.height = (src_new.height * af.scaleY) as int
        dest
    }

    /**
     * Given an arbitrary rectangle, get the rectangle with the inverse given transform.
     * The result rectangle is positive width and positive height.
     * @param af AffineTransform
     * @param src source rectangle
     * @return rectangle after transform with positive width and height
     */
    def static inverseTransformRect(AffineTransform af, Rectangle src) {
        var dest = new Rectangle(0, 0, 0, 0)
        var src_new = absRect(src)
        var p1 = new Point(src_new.x, src_new.y)
        p1 = inverseTransformPoint(af, p1)
        dest.x = p1.x; dest.y = p1.y
        dest.width = (src_new.width / af.scaleX) as int
        dest.height = (src_new.height / af.scaleY) as int
        dest
    }

    /**
     * Given an arbitrary point, get the point with the given transform.
     * @param af affine transform
     * @param pt point to be transformed
     * @return point after tranform
     */
    def static transformPoint(AffineTransform af, Point pt) {
        val src = new Point2D$Float(pt.x, pt.y)
        val dest= af.transform(src, null)
        new Point(Math::floor(dest.x) as int, Math::floor(dest.y) as int)
    }

    /**
     * Given an arbitrary point, get the point with the inverse given transform.
     * @param af AffineTransform
     * @param pt source point
     * @return point after transform
     */
    def static inverseTransformPoint(AffineTransform af, Point pt){
        val src = new Point2D$Float(pt.x, pt.y)
        try {
            val dest= af.inverseTransform(src, null)
            new Point(Math::floor(dest.x) as int, Math::floor(dest.y) as int)
        } catch (Exception e) {
            e.printStackTrace
            new Point(0, 0)
        }
    }

    /**
     * Given arbitrary rectangle, return a rectangle with upper-left 
     * start and positive width and height.
     * @param src source rectangle
     * @return result rectangle with positive width and height
     */
    def static absRect(Rectangle src) {
        var dest = new Rectangle(0, 0, 0, 0)
        if (src.width < 0) { dest.x = src.x + src.width + 1; dest.width = -src.width }
        else { dest.x = src.x; dest.width = src.width }
        if (src.height < 0) { dest.y = src.y + src.height + 1; dest.height = -src.height }
        else { dest.y = src.y; dest.height = src.height }
        dest
    }
}