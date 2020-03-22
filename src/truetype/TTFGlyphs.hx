package truetype;

import format.ttf.Data;


typedef GlyphContourPoint = {
	onCurve:Bool,
	x:Float,
	y:Float,
};

typedef GlyphContour = Array<GlyphContourPoint>;
typedef GlyphContours = Array<GlyphContour>;


class TTFGlyphs {
	public var headdata(default, null):HeadData;
	public var length(default, null):Int;
	var descriptions:Array<GlyfDescription>;

	public function new(ttfBytes:haxe.io.Bytes) {
		var bytesInput = new haxe.io.BytesInput(ttfBytes);
		var ttfReader:format.ttf.Reader = new format.ttf.Reader(bytesInput);
		var ttf:TTF = ttfReader.read();
		this.buildTables(ttf);
	}

	function buildTables(ttf:TTF) {
		for (table in ttf.tables) {
			switch table {
				case TGlyf(descriptions):
					trace('TGlyf descriptions: ' + descriptions.length);
					this.descriptions = descriptions;
					this.length = this.descriptions.length;
				case THead(headdata):
					this.headdata = headdata;
				default:
			}
		}
	}

	public function getGlyphSimple(index:Int):GlyphSimple {
		var description:GlyfDescription = this.descriptions[index];
		return switch description {
			case TGlyphSimple(h, data):
				data;
			case TGlyphComposite(h, components):
				// Still haven't found any Composite glyphs...
				throw 'TGlyphComposite $index';
				null;
			case TGlyphNull:
				trace('TGlyphNull $index');
				null;
		}
	}

	public function isGlyphSimple(index:Int):Bool {
		return this.getGlyphSimple(index) != null;
	}

	public function getGlyphHeader(index:Int):GlyphHeader {
		var description:GlyfDescription = this.descriptions[index];
		return switch description {
			case TGlyphSimple(header, data):
				header;
			case TGlyphComposite(header, components):
				header;
			case TGlyphNull:
				trace('TGlyphNull $index');
				null;
		}
	}

	public function getGlyphContours(index:Int):GlyphContours {
		var simple:GlyphSimple = getGlyphSimple(index);
		var points:GlyphContour = [];
		for (i in 0...simple.flags.length) {
			var onCurve = !(simple.flags[i] % 2 == 0);
			var point:GlyphContourPoint = {
				onCurve: onCurve,
				x: simple.xCoordinates[i],
				y: simple.yCoordinates[i],
			};
			points.push(point);
		}

		// split to sub-shapes
		var p = 0;
		var c = 0;
		var first = 1;

		var contour:GlyphContour = [];
		var contours = [];
		while (p < points.length) {
			var point = points[p];
			if (first == 1) {
				first = 0;
			} else {}
			contour.push(point);
			if (p == simple.endPtsOfContours[c]) {
				c += 1;
				first = 1;
				contours.push(contour.copy());
				contour = [];
			}
			p += 1;
		}

		// add interpolated points between offCurve points etc.
		this.adjustContours(contours);

		return contours;
	}

	public function adjustContours(contours:GlyphContours) {
		// Does this shape have an OnCurve point
		function hasOnCurve(contour:GlyphContour):Bool
			return contour.filter(i -> i.onCurve == true).length > 0;

		// Make first point an OnCurve one
		function shiftPoints(contour:GlyphContour) {
			var first = contour[0];
			while (first.onCurve == false) {
				contour.push(contour.shift());
				first = contour[0];
			}
		}

		// Create an OnCurve starting point
		function addControlPointOnCurve(contour:GlyphContour) {
			var p0 = contour[0];
			var p1 = contour[contour.length - 1];
			var newX = ((p1.x - p0.x) / 2) + p0.x;
			var newY = ((p1.y - p0.y) / 2) + p0.y;
			var newPoint:GlyphContourPoint = {x: newX, y: newY, onCurve: true};
			contour.unshift(newPoint);
		}

		for (contour in contours) {
			// trace('ADJUST CONTOUR: ');
			// trace('hasOnCurve:' + hasOnCurve(contour));
			if (hasOnCurve(contour)) {
				// trace('shift this one...');
				shiftPoints(contour);
			} else {
				addControlPointOnCurve(contour);
			}
		}

		// Add OnCurve points between succeeding OffCurve points
		for (contour in contours) {
			var newContour:GlyphContour = [];
			for (i in 0...contour.length) {
				// trace('check point ' + i);
				var point = contour[i];
				newContour.push(point);

				if (i > 0) {
					var prevPoint = contour[i - 1];
					if (point.onCurve == false && prevPoint.onCurve == false) {
						// trace('two offcurve in a row ' + i);
						var newX = ((point.x - prevPoint.x) / 2) + prevPoint.x;
						var newY = ((point.y - prevPoint.y) / 2) + prevPoint.y;
						var newPoint:GlyphContourPoint = {x: newX, y: newY, onCurve: true};
						// trace('point:' + point);
						// trace('prevPoint:' + prevPoint);
						// trace('newPoint:' + newPoint);
						newContour.insert(newContour.length - 1, newPoint);
					}
				}
			}

			// Add first point also as the last one
			newContour.push(newContour[0]);

			contours[contours.indexOf(contour)] = newContour;
		}
	}
}
