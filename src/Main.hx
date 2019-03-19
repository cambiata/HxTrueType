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
		for (i in 0...24)
			this.displayGlyph(i, fontUtils);
	}

	function displayGlyph(index:Int, utils:TTFGlyphUtils) {
		trace('=== index $index ================================');

		// Only works with GlyphSimple right now...
		// Seems to cover most cases
		var glyph:GlyphSimple = utils.getGlyphSimple(index);
		if (glyph == null)
			return;

		var contours = utils.getGlyphContours(index);
		var scale = (64 / utils.headdata.unitsPerEm) * 3;
		var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();
		Browser.document.body.appendChild(canvas);
		canvas.setAttribute('height', '250px');
		canvas.setAttribute('width', '250px');
		var ctx:CanvasRenderingContext2D = canvas.getContext2d();
		ctx.scale(scale, -scale);
		ctx.translate(-utils.headdata.xMin, -utils.headdata.yMin - (utils.headdata.yMax - utils.headdata.yMin));

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
		ctx.fillStyle = '#dddddd';
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
