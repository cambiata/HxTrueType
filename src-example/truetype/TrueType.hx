//-------------------------------------------------------------------------------------------
// Based on Steve Hanov's blog article "Let's read a Truetype file from scratch"
// http://stevehanov.ca/blog/?id=143
//-------------------------------------------------------------------------------------------
package truetype;

import truetype.data.Uint8Reader;
import typedarray.ArrayBuffer;
import haxe.ds.StringMap;

using Lambda;

class TrueTypeFont {
	function assert(condition:Bool, message:String = 'Assertion failed') {
		if (!condition) {
			// trace(message);
			throw message;
		}
	}

	//---------------------------------------------------------------
	var file:Uint8Reader;

	public function new(bytes:haxe.io.Bytes) {
		this.tables = new StringMap();

		this.file =
			#if js
			{
				var buffer:js.lib.ArrayBuffer = new js.lib.ArrayBuffer(bytes.length);
				var view:js.lib.DataView = new js.lib.DataView(buffer, 0, buffer.byteLength);
				for (i in 0...bytes.length)
					view.setUint8(i, bytes.get(i));
				new Uint8Reader(buffer);
			}
			#else
			new Uint8Reader(bytes);
			#end

		this.readOffsetTables(this.file);
		this.readHeadTable(this.file);
		this.length = this.glyphCount();

		
		// trace('Glyph offeset 1: ' + this.getGlyphOffset(1));
	}

	public var tables(default, null):StringMap<TableInfo>;
	public var length(default, null):Null<Int>;
	public var version(default, null):Null<Float>;
	public var fontRevision(default, null):Null<Float>;
	public var checksumAdjustment(default, null):Null<Int>;
	public var magicNumber(default, null):Null<Int>;
	public var flags(default, null):Null<Int>;
	public var unitsPerEm(default, null):Null<Int>;
	public var created(default, null):Date;
	public var modified(default, null):Date;
	public var xMin(default, null):Null<Int>;
	public var yMin(default, null):Null<Int>;
	public var xMax(default, null):Null<Int>;
	public var yMax(default, null):Null<Int>;
	public var macStyle(default, null):Null<Int>;
	public var lowestRecPPEM(default, null):Null<Int>;
	public var fontDirectionHint(default, null):Null<Int>;
	public var indexToLocFormat(default, null):Null<Int>;
	public var glyphDataFormat(default, null):Null<Int>;

	function readOffsetTables(file:Uint8Reader) {

		// trace('************* read offset tables *-************************');

		var scalarType = file.getUint32();
		var numTables = file.getUint16();
		var searchRange = file.getUint16();
		var entrySelector = file.getUint16();
		var rangeShift = file.getUint16();

		// trace('scalarType: ' + scalarType);
		// trace('numTables: ' + numTables);
		// trace('searchRange: ' + searchRange);
		// trace('entrySelector: ' + entrySelector);
		// trace('rangeShift: ' + rangeShift);

		for (i in 0...numTables) {
			var tag = file.getString(4);
			var checksum = file.getUint32();
			var offset = file.getUint32();
			var length = file.getUint32();

			this.tables.set(tag, {checksum: checksum, offset: offset, length: length});

			if (tag != 'head') {
				assert(this.calculateTableChecksum(file, this.tables.get(tag).offset, this.tables.get(tag).length) == this.tables.get(tag).checksum, 'Checksum fail');
			}
		}
		// trace('file.tell(): ' + file.tell());
		// trace('//////////////////////////////////////////////////////////////');

		return tables;
	}

	function calculateTableChecksum(file:Uint8Reader, offset:Int, length:Float):Float {
		var old = file.seek(offset);
		var sum:Int = 0;
		var nlongs:Float = Math.floor((length + 3) / 4) | 0;
		while (nlongs-- > 0) {
			sum = (sum + file.getUint32() & 0xffffffff) >>> 0;
		}

		file.seek(old);
		return sum;
	}

	function readHeadTable(file:Uint8Reader) {

		// trace('************* read head table *-************************');
		// trace('file.tell(): ' + file.tell());
		assert(this.tables.exists('head'));
		
		file.seek(this.tables.get("head").offset);

		this.version = file.getFixed();
		// trace('version: ' + version);
		// trace('file.tell(): ' + file.tell());
		this.fontRevision = file.getFixed();
		// trace('fontRevision: ' + fontRevision);
		this.checksumAdjustment = file.getUint32();
		// trace('checksumAdjustment: ' + checksumAdjustment);
		this.magicNumber = file.getUint32();
		// trace('magicNumber: ' + magicNumber);
		// assert(magicNumber == 0x5f0f3cf5, 'Magic number fail');
		this.flags = file.getUint16();
		// trace('flags: ' + flags);
		this.unitsPerEm = file.getUint16();
		// trace('unitsPerEm: ' + unitsPerEm);

		this.created = file.getDate();
		this.modified = file.getDate();
		this.xMin = file.getFword();
		this.yMin = file.getFword();
		this.xMax = file.getFword();
		this.yMax = file.getFword();
		this.macStyle = file.getUint16();
		this.lowestRecPPEM = file.getUint16();
		this.fontDirectionHint = file.getInt16();
		this.indexToLocFormat = file.getInt16();
		this.glyphDataFormat = file.getInt16();


		// trace('this.indexToLocFormat: ' + this.indexToLocFormat);
		// trace('////////////////////////////////////////////////////////');
	}

	function glyphCount():Int {
		assert(this.tables.exists('maxp'));
		var old = this.file.seek(this.tables.get("maxp").offset + 4);
		var count = this.file.getUint16();
		this.file.seek(old);
		return count;
	}

	function getGlyphOffset(index:Int):Int {
		assert(this.tables.exists("loca"));
		var table = this.tables.get('loca');
		// trace('table loc' + table);
		var offset:Int = 0;
		var old:Int = 0;
		
		// trace('this.indexToLocFormat: ' + this.indexToLocFormat);
		
		if (this.indexToLocFormat == 1) {
			// trace('table.offset + index * 4: ' + table.offset + index * 4);
			old = this.file.seek(table.offset + index * 4);
			offset = file.getUint32();
			// trace('offset 1: ' + offset);
		} else {
			old = file.seek(table.offset + index * 2);
			offset = file.getUint16() * 2;
			// trace('offset 2: ' + offset);
		}

		file.seek(old);
		
		// trace('offset 3: ' + offset);

		var glyphOffset = offset + this.tables.get("glyf").offset;
		// trace('Return glyphOffset: ' + glyphOffset);
		return glyphOffset;
	}

	public function readGlyph(index:Int) {
		var offset = this.getGlyphOffset(index);
		
		// trace('===== index/offset: ' + index + '/' + offset);

		var table = this.tables.get('glyf');

		if (offset >= table.offset + table.length) {
			return null;
		}

		assert(offset >= table.offset, 'Table offset problem for index $index');
		assert(offset < table.offset + table.length);

		file.seek(offset);

		var glyph:Glyph = {
			index: index,
			numberOfContours: file.getInt16(),
			xMin: file.getFword(),
			yMin: file.getFword(),
			xMax: file.getFword(),
			yMax: file.getFword(),
			type: null,
		};

		assert(glyph.numberOfContours >= -1);

		if (glyph.numberOfContours == -1) {
			// trace('readCompoundGlyph ' + index);
			this.readCompoundGlyph(this.file, glyph);
		} else {
			this.readSimpleGlyph(this.file, glyph);
		}

		return glyph;
	}

	function readSimpleGlyph(file:Uint8Reader, glyph:Glyph) {
		var ON_CURVE = 1, X_IS_BYTE = 2, Y_IS_BYTE = 4, REPEAT = 8, X_DELTA = 16, Y_DELTA = 32;

		var contourEnds = [];
		var points:Array<GlyphPoint> = [];

		for (i in 0...glyph.numberOfContours) {
			contourEnds.push(file.getUint16());
		}

		// skip over intructions
		file.seek(file.getUint16() + file.tell());

		if (glyph.numberOfContours == 0) {
			return;
		}

		var numPoints = Math.round(contourEnds.fold((v, max) -> Math.max(v, max), 0)) + 1;
		var flags:Array<Int> = [];

		// trace('File tell before: ' + file.tell());
		// trace(numPoints);
		//-------------------------------------------
		// Read onCurve parameter
		var count = 0;
		var i = 0;
		// for (i in 0...numPoints ) {
			
			// trace('glyph.index: ' + glyph.index + ' ---------------------------');
			// trace('numPoints:' + numPoints  );
			// trace('File tell before: ' + file.tell());
			
	
		while (i < numPoints) {
			var flag:Int = file.getUint8();
			flags.push(flag);
			points.push({
				c: (flag & ON_CURVE) > 0,
				x: 0,
				y: 0,
			});

			// trace(i + ':' + count + ' flag: ' + flag + ' ' + file.tell() + ' ' + (flag & REPEAT));

			if ((flag & REPEAT) != 0) {
				// trace('FLAG AND REPEAT');
				var repeatCount:Int = file.getUint8();
				assert(repeatCount > 0, 'Repeat count problem! for index ' + glyph.index   );
				// var i2 = i;
				i += repeatCount;
				while (repeatCount-- > 0) {
					flags.push(flag);
					points.push({
						c: (flag & ON_CURVE) > 0,
						x: 0,
						y: 0,
					});
				}
			}
			count++;
			i++;
		}
		// trace(flags.length);
		// trace('count: ' + count);

		//-------------------------------------------
		// Read x parameter
		// trace('File tell before2: ' + file.tell());
		var value = 0;
		for (i in 0...numPoints) {
			var flag:Int = flags[i];
			if (flag & X_IS_BYTE != 0) {
				if (flag & X_DELTA != 0) {
					value += file.getUint8();
				} else {
					value -= file.getUint8();
				}
			} else if (~flag & X_DELTA != 0) {
				value += file.getInt16();
			} else {
				// value is unchanged.
			}
			points[i].x = value;
		}

		//-------------------------------------------
		// Read y parameter
		var value = 0;
		// trace('File tell before3: ' + file.tell());
		for (i in 0...numPoints) {
			var flag:Int = flags[i];
			if (flag & Y_IS_BYTE != 0) {
				if (flag & Y_DELTA != 0) {
					value += file.getUint8();
				} else {
					value -= file.getUint8();
				}
			} else if (~flag & Y_DELTA != 0) {
				value += file.getInt16();
			} else {
				// value is unchanged.
			}

			points[i].y = value;
		}

		//---------------------------------------

		var p = 0, c = 0;
		var points2 = [];
		var subPoints = [];
		while (p < points.length) {
			var point = points[p];
			subPoints.push(point);
			if (p == contourEnds[c]) {
				c += 1;
				points2.push(subPoints);
				subPoints = new Array();
			}
			p += 1;
		}

		adjustOutlines(points2);
		//
		glyph.type = Simple(points2);
	}

	function readCompoundGlyph(file:Uint8Reader, glyph:Glyph) {
		var ARG_1_AND_2_ARE_WORDS = 1,
			ARGS_ARE_XY_VALUES = 2,
			ROUND_XY_TO_GRID = 4,
			WE_HAVE_A_SCALE = 8, // RESERVED              = 16
			MORE_COMPONENTS = 32,
			WE_HAVE_AN_X_AND_Y_SCALE = 64,
			WE_HAVE_A_TWO_BY_TWO = 128,
			WE_HAVE_INSTRUCTIONS = 256,
			USE_MY_METRICS = 512,
			OVERLAP_COMPONENT = 1024;

		var components = [];

		var flags = MORE_COMPONENTS;
		while (flags & MORE_COMPONENTS != 0) {
			var arg1:Null<Int> = null;
			var arg2:Null<Int> = null;
			flags = file.getUint16();
			var component:GlyphComponent = {
				glyphIndex: file.getUint16(),
				matrix: {
					a: 1,
					b: 0,
					c: 0,
					d: 1,
					e: 0,
					f: 0
				},
				destPointIndex: null,
				srcPointIndex: null,
			};

			if (flags & ARG_1_AND_2_ARE_WORDS != 0) {
				arg1 = file.getInt16();
				arg2 = file.getInt16();
			} else {
				arg1 = file.getUint8();
				arg2 = file.getUint8();
			}

			if (flags & ARGS_ARE_XY_VALUES != 0) {
				component.matrix.e = arg1;
				component.matrix.f = arg2;
			} else {
				component.destPointIndex = arg1;
				component.srcPointIndex = arg2;
			}

			if (flags & WE_HAVE_A_SCALE != 0) {
				component.matrix.a = file.get2Dot14();
				component.matrix.d = component.matrix.a;
			} else if (flags & WE_HAVE_AN_X_AND_Y_SCALE != 0) {
				component.matrix.a = file.get2Dot14();
				component.matrix.d = file.get2Dot14();
			} else if (flags & WE_HAVE_A_TWO_BY_TWO != 0) {
				component.matrix.a = file.get2Dot14();
				component.matrix.b = file.get2Dot14();
				component.matrix.c = file.get2Dot14();
				component.matrix.d = file.get2Dot14();
			}

			components.push(component);
		}

		if (flags & WE_HAVE_INSTRUCTIONS != 0) {
			file.seek(file.getUint16() + file.tell());
		}

		//-----------------------------------------------------
		glyph.type = Compound(components);
	}

	public function adjustOutlines(outlines:Array<Array<GlyphPoint>>) {
		// Does this shape have an OnCurve point
		function hasOnCurve(outline:Array<GlyphPoint>):Bool
			return outline.filter(i -> i.c == true).length > 0;

		// Make first point an OnCurve one
		function shiftPoints(outline:Array<GlyphPoint>) {
			var first = outline[0];
			while (first.c == false) {
				outline.push(outline.shift());
				first = outline[0];
			}
		}

		// Create an OnCurve starting point
		function addControlPointOnCurve(outline:Array<GlyphPoint>) {
			var p0 = outline[0];
			var p1 = outline[outline.length - 1];
			var newX = ((p1.x - p0.x) / 2) + p0.x;
			var newY = ((p1.y - p0.y) / 2) + p0.y;
			var newPoint:GlyphPoint = {x: newX, y: newY, c: true};
			outline.unshift(newPoint);
		}

		for (outline in outlines) {
			// // trace('ADJUST Outline: ');
			// // trace('hasOnCurve:' + hasOnCurve(outline));
			if (hasOnCurve(outline)) {
				// // trace('shift this one...');
				shiftPoints(outline);
			} else {
				addControlPointOnCurve(outline);
			}
		}

		// Add OnCurve points between succeeding OffCurve points
		for (outline in outlines) {
			var newOutline:Array<GlyphPoint> = [];
			for (i in 0...outline.length) {
				// // trace('check point ' + i);
				var point = outline[i];
				newOutline.push(point);

				if (i > 0) {
					var prevPoint = outline[i - 1];
					if (point.c == false && prevPoint.c == false) {
						var newX = ((point.x - prevPoint.x) / 2) + prevPoint.x;
						var newY = ((point.y - prevPoint.y) / 2) + prevPoint.y;
						var newPoint:GlyphPoint = {x: newX, y: newY, c: true};
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

typedef Glyph = {
	index:Int,
	numberOfContours:Int,
	xMin:Int,
	yMin:Int,
	xMax:Int,
	yMax:Int,
	type:GlyphType,
}

enum GlyphType {
	Simple(points2:Array<Array<GlyphPoint>>);
	Compound(components:Array<GlyphComponent>);
}



typedef GlyphComponent = {
	glyphIndex:Int,
	matrix:{
		a:Float, b:Float, c:Float, d:Float, e:Float, f:Float
	},
	destPointIndex:Null<Int>,
	srcPointIndex:Null<Int>,
}

typedef TableInfo = {checksum:Int, offset:Int, length:Int};
