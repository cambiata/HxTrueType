package truetype;

import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import format.ttf.Data;

class Glyph2SVG {

    static public function getGlyphSvg(ttfGlyphs:TTFGlyphs, index:Int, displayScale:Float = .5, translateY:Float=-1350, fillColor:String = "#a00"):Xml {
		// Only works with GlyphSimple right now...
		// Seems to cover most cases
		var glyph:GlyphSimple = ttfGlyphs.getGlyphSimple(index);
		if (glyph == null)
			throw 'Glyph index $index is not of type GlyphSimple';

		var glyphHeader:GlyphHeader = ttfGlyphs.getGlyphHeader(index);
       
        var scale = (64 / ttfGlyphs.headdata.unitsPerEm) * displayScale;
		var canvasWidth = (glyphHeader.xMax + 5) * scale;
		var canvasHeight = (ttfGlyphs.headdata.yMax + 300) * scale;
		var contours:GlyphContours = ttfGlyphs.getGlyphContours(index);
		//--------------------------------------------------------------------
		// Draw glyph outline
		var svgPath = [];
		for (contour in contours) {
            var offCurvePoint:GlyphContourPoint = null;
			for (i in 0...contour.length) {
                var point = contour[i];
				if (i == 0) {
                    svgPath.push('M ${point.x} ${point.y}');
				} else {
                    var prevPoint = contour[i - 1];
					if (point.onCurve) {
                        if (prevPoint.onCurve) {
                            svgPath.push('L ${point.x} ${point.y}');
						} else {
                            svgPath.push("Q " + offCurvePoint.x + " " + offCurvePoint.y + " " + point.x + " " + point.y);
						}
					} else {
                        offCurvePoint = contour[i];
					}
				}
			}
		}
        
        //--------------------------------------------------------------------
        // Build SVG element
        var path = Xml.createElement('path');
        path.set('fill', fillColor);
        path.set('d', svgPath.join(' '));

        var scale = 0.064 * displayScale;
        path.set('transform', 'scale($scale, -$scale) translate(0, $translateY)');

        var svg = Xml.createElement('svg');
        svg.set('xmlns', 'http://www.w3.org/2000/svg');
        svg.set('width', canvasWidth + "px");
        svg.set('height', canvasHeight + "px");

        svg.addChild(path);
		
        return svg;
    }   
}