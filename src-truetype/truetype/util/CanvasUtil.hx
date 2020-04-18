package truetype.util;

class CanvasUtil {

    static public function drawGlyphOnCanvasContext2D(ctx:js.html.CanvasRenderingContext2D, points2:Array<Array<GlyphPoint>>, pointsScale:Float, translateY:Float, x:Float = 0, y:Float = 0, drawPoints=true, drawStroke=false) {
		// var scale = (64 / unitsPerEm) * displayScale;

		ctx.scale(pointsScale, -pointsScale);
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
		// ctx.fillStyle = fillColor;
		ctx.fill();
		if (drawStroke) {
            ctx.stroke();            
            ctx.strokeStyle = 'red';
            ctx.lineWidth = 3;
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
}