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
// typedef ContourPoint = {
// 	onCurve:Bool,
// 	x:Float,
// 	y:Float,
// };
// typedef Contour = Array<ContourPoint>;
// typedef Contours = Array<Contour>;
// class TTFGlyphUtils {
// 	var descriptions:Array<GlyfDescription>;
// 	public var headdata:HeadData;
// 	public var length:Int;
// 	public function new(ttf:TTF) {
// 		for (table in ttf.tables) {
// 			switch table {
// 				case TGlyf(descriptions):
// 					trace('TGlyf descriptions: ' + descriptions.length);
// 					this.descriptions = descriptions;
// 					this.length = this.descriptions.length;
// 				case THead(headdata):
// 					this.headdata = headdata;
// 				default:
// 			}
// 		}
// 	}
// 	public function getGlyphSimple(index):GlyphSimple {
// 		var description:GlyfDescription = this.descriptions[index];
// 		var header:GlyphHeader = null;
// 		var simple:GlyphSimple = null;
// 		switch description {
// 			case TGlyphSimple(h, data):
// 				simple = data;
// 			case TGlyphComposite(h, components):
// 				throw 'TGlyphComposite $index';
// 			case TGlyphNull:
// 				trace('TGlyphNull $index');
// 		}
// 		return simple;
// 	}
// 	public function getGlyphContours(index:Int):Array<Array<ContourPoint>> {
// 		var simple:GlyphSimple = getGlyphSimple(index);
// 		var points:Contour = [];
// 		for (i in 0...simple.flags.length) {
// 			var onCurve = !(simple.flags[i] % 2 == 0);
// 			var point:ContourPoint = {
// 				onCurve: onCurve,
// 				x: simple.xCoordinates[i],
// 				y: simple.yCoordinates[i],
// 			};
// 			points.push(point);
// 		}
// 		// split to sub-shapes
// 		var p = 0;
// 		var c = 0;
// 		var first = 1;
// 		var contour:Array<ContourPoint> = [];
// 		var contours = [];
// 		while (p < points.length) {
// 			var point = points[p];
// 			if (first == 1) {
// 				first = 0;
// 			} else {}
// 			contour.push(point);
// 			if (p == simple.endPtsOfContours[c]) {
// 				c += 1;
// 				first = 1;
// 				contours.push(contour.copy());
// 				contour = [];
// 			}
// 			p += 1;
// 		}
// 		// add interpolated points between offCurve points etc.
// 		this.adjustContours(contours);
// 		return contours;
// 	}
// 	public function adjustContours(contours:Contours) {
// 		function hasOnCurve(contour:Contour):Bool
// 			return contour.filter(i -> i.onCurve == true).length > 0;
// 		function shiftPoints(contour:Contour) {
// 			var count = 0;
// 			var first = contour[0];
// 			while (first.onCurve == false) {
// 				if (count++ > contour.length)
// 					throw "AJAJJAJJJAJJJJ";
// 				contour.push(contour.shift());
// 				first = contour[0];
// 			}
// 		}
// 		function addControlPointOnCurve(contour:Contour) {
// 			var p0 = contour[0];
// 			var p1 = contour[contour.length - 1];
// 			var newX = ((p1.x - p0.x) / 2) + p0.x;
// 			var newY = ((p1.y - p0.y) / 2) + p0.y;
// 			var newPoint:ContourPoint = {x: newX, y: newY, onCurve: true};
// 			contour.unshift(newPoint);
// 		}
// 		for (contour in contours) {
// 			trace('ADJUST CONTOUR: ');
// 			trace('hasOnCurve:' + hasOnCurve(contour));
// 			if (hasOnCurve(contour)) {
// 				trace('shift this one...');
// 				shiftPoints(contour);
// 			} else {
// 				addControlPointOnCurve(contour);
// 			}
// 		}
// 		for (contour in contours) {
// 			var newContour:Contour = [];
// 			for (i in 0...contour.length) {
// 				trace('check point ' + i);
// 				var point = contour[i];
// 				newContour.push(point);
// 				if (i > 0) {
// 					var prevPoint = contour[i - 1];
// 					if (point.onCurve == false && prevPoint.onCurve == false) {
// 						trace('two offcurve in a row ' + i);
// 						var newX = ((point.x - prevPoint.x) / 2) + prevPoint.x;
// 						var newY = ((point.y - prevPoint.y) / 2) + prevPoint.y;
// 						var newPoint:ContourPoint = {x: newX, y: newY, onCurve: true};
// 						trace('point:' + point);
// 						trace('prevPoint:' + prevPoint);
// 						trace('newPoint:' + newPoint);
// 						newContour.insert(newContour.length - 1, newPoint);
// 					}
// 				}
// 			}
// 			newContour.push(newContour[0]);
// 			contours[contours.indexOf(contour)] = newContour;
// 		}
// 	}
// }
