package truetype;

import js.Browser;
import js.html.CanvasElement;
import truetype.GlyphOutline;
import truetype.TTFGlyphs;
import format.ttf.Data;

class Glyph2Canvas {

	// Add some extra space to the rendered area
	static var ADD_TO_GLYPH_WIDTH = 5;
	static var ADD_TO_GLYPH_HEIGHT = 100;

	static public function getGlyphCanvas(glyphInfo:GlyphInfo, displayScale:Float = .5, translateY:Float=-1000, fillColor:String = "#00a", drawPoints:Bool = false, drawStroke:Bool=true):CanvasElement {
		var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();
		var index = glyphInfo.index;
        var scale = (64 / glyphInfo.unitsPerEm) * displayScale;
		var canvasWidth = glyphInfo.xMax * scale + ADD_TO_GLYPH_WIDTH;
		var canvasHeight = glyphInfo.yMax * scale + ADD_TO_GLYPH_HEIGHT;

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

		for (outline in glyphInfo.outlines) {
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
		ctx.fillStyle = fillColor;
		ctx.fill();
		if (drawStroke) {
			ctx.lineWidth = displayScale;
			ctx.stroke();
		}

		// ----------------------------------------
		// Draw points
		if (drawPoints) {
			for (outline in glyphInfo.outlines) {
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