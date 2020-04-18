package truetype;

import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.CanvasElement;
import truetype.GlyphOutline;
import truetype.TTFGlyphs;
import format.ttf.Data;


class Glyph2Canvas {

	// Add some extra space to the rendered area
	static var ADD_TO_GLYPH_WIDTH = 5;
	static var ADD_TO_GLYPH_HEIGHT = 100;

	static public function drawGlyphOnCanvasContext2D(ctx:CanvasRenderingContext2D, points2:Array<Array<GlyphPoint>>, unitsPerEm:Float, x:Float, y:Float, displayScale:Float = .5, translateY:Float=-1000, fillColor:String = "#00a", drawPoints:Bool = true, drawStroke:Bool=true) {

		var scale = (64 / unitsPerEm) * displayScale;

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

		for (outline in points2) {
			var offCurvePoint:GlyphPoint = null;
			for (i in 0...outline.length) {
				var point = outline[i];
				if (i == 0) {
					ctx.moveTo(x + point.x, y + point.y);
				} else {
					var prevPoint = outline[i - 1];
					if (point.c) { // curve?
						if (prevPoint.c) {
							ctx.lineTo(x + point.x, y + point.y);
						} else {
							ctx.quadraticCurveTo(x + offCurvePoint.x, y + offCurvePoint.y, x + point.x, y + point.y);
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
			for (outline in points2) {
				for (point in outline) {
					if (point == outline[0]) {
						ctx.beginPath();
						ctx.fillStyle = '#0000ff';
						ctx.rect(x + point.x - 20, y + point.y - 20, 40, 40);
						ctx.fill();
					}

					ctx.beginPath();
					if (point.c)
						ctx.fillStyle = '#ff0000';
					else
						ctx.fillStyle = '#00ff00';
					ctx.rect(x + point.x - 10, y + point.y - 10, 20, 20);
					ctx.fill();
				}
			}
		}
		
		//---------------------------------------------
		// Restore scaling and transformation
		ctx.resetTransform();		
		ctx.restore();

	}

	static public function getGlyphCanvas(glyphInfo:GlyphInfo, displayScale:Float = .5, translateY:Float=-1000, fillColor:String = "#00a", drawPoints:Bool = true, drawStroke:Bool=true):CanvasElement {
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

		drawGlyphOnCanvasContext2D(ctx, glyphInfo.outlines, glyphInfo.unitsPerEm, 0, 0, displayScale, translateY, fillColor, drawPoints, drawStroke);
		
		return canvas;
	}    

		

}