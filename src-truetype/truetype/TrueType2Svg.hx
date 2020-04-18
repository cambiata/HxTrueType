package truetype;

import truetype.util.SvgUtils;

class TrueType2Svg extends truetype.base.TrueType2Base {
	public function getGlyphSvg2(indexOrGlyph:cx.OneOf<Int, Glyph>):Xml {
		var glyph = switch indexOrGlyph {
			case Either.Left(index):
				var glyph = trueTypeFont.readGlyph(index);
				if (glyph == null)
					throw 'Can not create glyph for index $index';
				glyph;
			case Either.Right(glyph): glyph;
		}
		//--------------------------------------------------------------------
		// Draw glyph outline

		var svgPaths = [];
		switch glyph.type {
			case Simple(points2):
				// trace('Simple');
				var svgPath = SvgUtils.getPathFromPoints(points2);
				svgPaths.push(svgPath);
			case Compound(components):
				// trace('Compound');
				for (component in components) {
					var compIndex = component.glyphIndex;
					var compGlyph = this.trueTypeFont.readGlyph(compIndex);
					var compMatrix = component.matrix;
					switch compGlyph.type {
						case Simple(points2):
							// trace('- Simple in Compound');
							var moveX = compMatrix.e;
							var moveY = compMatrix.f;
							if (moveX != 0 || moveY != 0)
								points2 = points2.map(points -> points.map(point -> {x: point.x + moveX, y: point.y + moveY, c: point.c}));
							var svgPath = SvgUtils.getPathFromPoints(points2);
							svgPaths.push(svgPath);
						case Compound(components):
							trace("Compound in compound - should this be possible? index " + compGlyph.index);
					}
				}
		}
		// trace('SvgPaths length ' + svgPaths.length);
		//--------------------------------------------------------------------
		// Build SVG element
		var svgWidth = glyph.xMax * this.pointsScale + ADD_TO_GLYPH_WIDTH;
		var svgHeight = fontYMax * this.pointsScale + ADD_TO_GLYPH_HEIGHT;

		var svg = Xml.createElement('svg');
		svg.set('xmlns', 'http://www.w3.org/2000/svg');
		svg.set('width', svgWidth + "px");
		svg.set('height', svgHeight + "px");

		for (svgPath in svgPaths) {
			var path = Xml.createElement('path');
			path.set('fill', fillColor);
			path.set('d', svgPath);
			var scale = this.pointsScale * displayScale * .335;
			path.set('transform', 'scale($scale, -$scale) translate(0, $translateY)');
			svg.addChild(path);
		}

		return svg;
	}
}
