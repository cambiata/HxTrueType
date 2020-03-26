package truetype;

import format.ttf.Data;
import truetype.GlyphOutline;

class TTFGlyphs {
	public var headdata(default, null):HeadData;
	public var length(default, null):Int;
	var descriptions:Array<GlyfDescription>;
	public var fontName(default, null):String;

	public function new(ttfBytes:haxe.io.Bytes) {
		var bytesInput = new haxe.io.BytesInput(ttfBytes);
		var ttfReader:format.ttf.Reader = new format.ttf.Reader(bytesInput);
		var ttf:TTF = ttfReader.read();
		this.fontName = ttfReader.fontName;
		this.buildTables(ttf);		
	}

	function buildTables(ttf:TTF) {
		for (table in ttf.tables) {
			switch table {
				case TGlyf(descriptions):					
					this.descriptions = descriptions;
					this.length = this.descriptions.length;
				case THead(headdata):
					this.headdata = headdata;
				default:
			}
		}
	}

	public function getGlyphSimple(index:Int):GlyphSimple {
		if (this.descriptions[index] == null) {
			trace('Can not get description for glyph index $index');
			return null;
		}
		var description:GlyfDescription = this.descriptions[index];
		return switch description {
			case TGlyphSimple(h, data):
				data;
			case TGlyphComposite(h, components):
				// Still haven't found any Composite glyphs...
				// trace('TGlyphNull $index');
				// throw 'TGlyphComposite $index';
				null;
			case TGlyphNull:
				// trace('TGlyphNull $index');
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

	public function getGlyphOutlines(index:Int):GlyphOutlines {
		var simple:GlyphSimple = getGlyphSimple(index);
		var points:GlyphOutline = [];
		for (i in 0...simple.flags.length) {
			var onCurve = !(simple.flags[i] % 2 == 0);
			var point:GlyphOutlinePoint = {
				c: onCurve,
				x: simple.xCoordinates[i],
				y: simple.yCoordinates[i],
			};
			points.push(point);
		}

		// split to sub-shapes
		var p = 0;
		var c = 0;
		var first = 1;

		var outline:GlyphOutline = [];
		var outlines = [];
		while (p < points.length) {
			var point = points[p];
			if (first == 1) {
				first = 0;
			} else {}
			outline.push(point);
			if (p == simple.endPtsOfContours[c]) {
				c += 1;
				first = 1;
				outlines.push(outline.copy());
				outline = [];
			}
			p += 1;
		}

		// add interpolated points between offCurve points etc.
		this.adjustOutlines(outlines);

		return outlines;
	}

	public function adjustOutlines(outlines:GlyphOutlines) {
		// Does this shape have an OnCurve point
		function hasOnCurve(outline:GlyphOutline):Bool
			return outline.filter(i -> i.c == true).length > 0;

		// Make first point an OnCurve one
		function shiftPoints(outline:GlyphOutline) {
			var first = outline[0];
			while (first.c == false) {
				outline.push(outline.shift());
				first = outline[0];
			}
		}

		// Create an OnCurve starting point
		function addControlPointOnCurve(outline:GlyphOutline) {
			var p0 = outline[0];
			var p1 = outline[outline.length - 1];
			var newX = ((p1.x - p0.x) / 2) + p0.x;
			var newY = ((p1.y - p0.y) / 2) + p0.y;
			var newPoint:GlyphOutlinePoint = {x: newX, y: newY, c: true};
			outline.unshift(newPoint);
		}

		for (outline in outlines) {
			// trace('ADJUST Outline: ');
			// trace('hasOnCurve:' + hasOnCurve(outline));
			if (hasOnCurve(outline)) {
				// trace('shift this one...');
				shiftPoints(outline);
			} else {
				addControlPointOnCurve(outline);
			}
		}

		// Add OnCurve points between succeeding OffCurve points
		for (outline in outlines) {
			var newOutline:GlyphOutline = [];
			for (i in 0...outline.length) {
				// trace('check point ' + i);
				var point = outline[i];
				newOutline.push(point);

				if (i > 0) {
					var prevPoint = outline[i - 1];
					if (point.c == false && prevPoint.c == false) {
						// trace('two offcurve in a row ' + i);
						var newX = ((point.x - prevPoint.x) / 2) + prevPoint.x;
						var newY = ((point.y - prevPoint.y) / 2) + prevPoint.y;
						var newPoint:GlyphOutlinePoint = {x: newX, y: newY, c: true};
						// trace('point:' + point);
						// trace('prevPoint:' + prevPoint);
						// trace('newPoint:' + newPoint);
						newOutline.insert(newOutline.length - 1, newPoint);
					}
				}
			}

			// Add first point also as the last one
			newOutline.push(newOutline[0]);

			outlines[outlines.indexOf(outline)] = newOutline;
		}
	}
}
