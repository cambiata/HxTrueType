package truetype;

import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import truetype.GlyphOutline;
import format.ttf.Data;

class Glyph2SVG {    

	// Add some extra space to the rendered area
	static var ADD_TO_GLYPH_WIDTH = 5;
	static var ADD_TO_GLYPH_HEIGHT = 100;

	static public function getGlyphSvg(glyphInfo:GlyphInfo,  displayScale:Float = .5, translateY:Float = -1000, fillColor:String = "#4a4ad1"):Xml {
		var scale = (64 / glyphInfo.unitsPerEm) * displayScale;
		var svgWidth = glyphInfo.xMax * scale + ADD_TO_GLYPH_WIDTH;
		var svgHeight = glyphInfo.yMax * scale + ADD_TO_GLYPH_HEIGHT;
		
		//--------------------------------------------------------------------
		// Draw glyph outline
		var svgPath = [];
		for (outline in glyphInfo.outlines) {
			var offCurvePoint:GlyphOutlinePoint = null;
			for (i in 0...outline.length) {
				var point = outline[i];
				if (i == 0) {
					svgPath.push('M ${point.x} ${point.y}');
				} else {
					var prevPoint = outline[i - 1];
					if (point.c) { // curve?
						if (prevPoint.c) {
							svgPath.push('L ${point.x} ${point.y}');
						} else {
							svgPath.push("Q " + offCurvePoint.x + " " + offCurvePoint.y + " " + point.x + " " + point.y);
						}
					} else {
						offCurvePoint = outline[i];
					}
				}
			}
		}

		//--------------------------------------------------------------------
		// Build SVG element

		var path = Xml.createElement('path');
		path.set('fill', fillColor);
		path.set('d', svgPath.join(' '));

		final MAGIC_SVG_SCALE = 0.064; // Used to scale the rendered SVG glyphs to the same size as Canvas glyphs...
		var scale = MAGIC_SVG_SCALE * displayScale;
		path.set('transform', 'scale($scale, -$scale) translate(0, $translateY)');

		var svg = Xml.createElement('svg');
		svg.set('xmlns', 'http://www.w3.org/2000/svg');
		svg.set('width', svgWidth + "px");
		svg.set('height', svgHeight + "px");

		svg.addChild(path);

		return svg;
	}
}
