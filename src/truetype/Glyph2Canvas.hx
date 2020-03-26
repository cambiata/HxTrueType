package truetype;

import js.Browser;
import js.html.CanvasElement;
import truetype.GlyphOutline;
import truetype.TTFGlyphs;
import format.ttf.Data;

class Glyph2Canvas {
	static public function getGlyphCanvas(ttfGlyphs:TTFGlyphs, index:Int, displayScale:Float = .5, translateY:Float=-1350, fillColor:String = "#00a", drawPoints:Bool = false):CanvasElement {
		// Only works with GlyphSimple right now...
		// Seems to cover most cases
		var glyph:GlyphSimple = ttfGlyphs.getGlyphSimple(index);
		if (glyph == null)
			throw 'Glyph index $index is not of type GlyphSimple';

		var glyphHeader:GlyphHeader = ttfGlyphs.getGlyphHeader(index);
		var outlines = ttfGlyphs.getGlyphOutlines(index);
		var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();

        var scale = (64 / ttfGlyphs.headdata.unitsPerEm) * displayScale;
		var canvasWidth = (glyphHeader.xMax + 5) * scale;
		var canvasHeight = (ttfGlyphs.headdata.yMax + 300) * scale;

        canvas.setAttribute('height', '${canvasHeight}px');
		canvas.setAttribute('width', '${canvasWidth}px');
		var ctx:js.html.CanvasRenderingContext2D = canvas.getContext2d();
		ctx.font = "16px Arial";
		ctx.fillText('$index', 8, 20);
		ctx.scale(scale, -scale);
		ctx.translate(0, translateY);


		// --------------------------------------------------------------------
		// Draw bounding box
		// ctx.beginPath();
		// ctx.rect(glyphHeader.xMin, glyphHeader.yMin, glyphHeader.xMax - glyphHeader.xMin, glyphHeader.yMax - glyphHeader.yMin);
		// ctx.stroke();

		// ctx.beginPath();
		// ctx.rect(0, 0, glyphHeader.xMax, glyphHeader.yMax);
        // ctx.stroke();
        
		//--------------------------------------------------------------------
		// Draw glyph outline
		ctx.beginPath();

		for (outline in outlines) {
			var offCurvePoint:GlyphOutlinePoint = null;
			for (i in 0...outline.length) {
				var point = outline[i];
				if (i == 0) {
					ctx.moveTo(point.x, point.y);
				} else {
					var prevPoint = outline[i - 1];
					if (point.c) { // curve?
						if (prevPoint.c) {
							ctx.lineTo(point.x, point.y);
						} else {
							ctx.quadraticCurveTo(offCurvePoint.x, offCurvePoint.y, point.x, point.y);
						}
					} else {
						offCurvePoint = outline[i];
					}
				}
			}
		}
		ctx.fillStyle = '#00a';
		ctx.fill();
		// ctx.lineWidth = 3;
		// ctx.stroke();

		// ----------------------------------------
		// Draw points
		if (drawPoints) {
			for (outline in outlines) {
				for (point in outline) {
					if (point == outline[0]) {
						ctx.beginPath();
						ctx.fillStyle = '#0000ff';
						ctx.rect(point.x - 20, point.y - 20, 40, 40);
						ctx.fill();
					}

					ctx.beginPath();
					if (point.c)
						ctx.fillStyle = '#ff0000';
					else
						ctx.fillStyle = '#00ff00';
					ctx.rect(point.x - 10, point.y - 10, 20, 20);
					ctx.fill();
				}
			}
        }
        //--------------------------------------------------
		return canvas;
	}    
}