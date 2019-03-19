import js.Browser;
import js.html.CanvasRenderingContext2D;
import haxe.io.BytesInput;
import truetype.TTFGlyphUtils;
import format.ttf.Data;

class Main {
	static public function main()
		new Main();

	var descriptions:Array<GlyfDescription>;

	public function new() {
		var bytes = haxe.Resource.getBytes("font");
		var bytesInput = new BytesInput(bytes);
		var ttfReader:format.ttf.Reader = new format.ttf.Reader(bytesInput);
		var ttf:TTF = ttfReader.read();
		var fontUtils = new TTFGlyphUtils(ttf);
		for (i in 0...128)
			this.displayGlyph(i, fontUtils);

		// this.displayGlyph(9, fontUtils);
	}

	function displayGlyph(index:Int, utils:TTFGlyphUtils, displayScale = 4) {
		trace('=== index $index ================================');

		// Only works with GlyphSimple right now...
		// Seems to cover most cases
		var glyph:GlyphSimple = utils.getGlyphSimple(index);
		if (glyph == null)
			return;

		var glyphHeader:GlyphHeader = utils.getGlyphHeader(index);
		trace(glyphHeader);

		var contours = utils.getGlyphContours(index);
		var scale = (64 / utils.headdata.unitsPerEm) * displayScale;
		var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();
		Browser.document.body.appendChild(canvas);

		var canvasWidth = (glyphHeader.xMax + 5) * scale;
		var canvasHeight = (utils.headdata.yMax + 300) * scale;
		canvas.setAttribute('height', '${canvasHeight}px');
		canvas.setAttribute('width', '${canvasWidth}px');
		var ctx:CanvasRenderingContext2D = canvas.getContext2d();

		ctx.scale(scale, -scale);
		ctx.translate(0, -utils.headdata.yMax);

		// --------------------------------------------------------------------
		// Draw bounding box

		ctx.beginPath();
		ctx.rect(glyphHeader.xMin, glyphHeader.yMin, glyphHeader.xMax - glyphHeader.xMin, glyphHeader.yMax - glyphHeader.yMin);
		ctx.stroke();

		ctx.beginPath();
		ctx.rect(0, 0, glyphHeader.xMax, glyphHeader.yMax);
		ctx.stroke();
		//--------------------------------------------------------------------
		// Draw glyph outline
		ctx.beginPath();
		for (contour in contours) {
			var offCurvePoint = null;
			for (i in 0...contour.length) {
				var point = contour[i];
				if (i == 0) {
					ctx.moveTo(point.x, point.y);
				} else {
					var prevPoint = contour[i - 1];
					if (point.onCurve) {
						if (prevPoint.onCurve) {
							ctx.lineTo(point.x, point.y);
						} else {
							ctx.quadraticCurveTo(offCurvePoint.x, offCurvePoint.y, point.x, point.y);
						}
					} else {
						offCurvePoint = contour[i];
					}
				}
			}
		}
		ctx.fillStyle = '#eeeeee';
		ctx.fill();
		ctx.lineWidth = 3;
		ctx.stroke();

		// ----------------------------------------
		// Draw points
		for (contour in contours) {
			for (point in contour) {
				if (point == contour[0]) {
					ctx.beginPath();
					ctx.fillStyle = '#0000ff';
					ctx.rect(point.x - 20, point.y - 20, 40, 40);
					ctx.fill();
				}

				ctx.beginPath();
				if (point.onCurve)
					ctx.fillStyle = '#ff0000';
				else
					ctx.fillStyle = '#00ff00';
				ctx.rect(point.x - 10, point.y - 10, 20, 20);
				ctx.fill();
			}
		}
	}
}
