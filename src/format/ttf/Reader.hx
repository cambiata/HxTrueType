/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;

import format.ttf.Data;
import format.ttf.Constants;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.ds.StringMap as Hash;

class Reader {
	var input:haxe.io.Input;
	var tablesHash:Hash<Bytes>;
	var glyphIndexArray:Array<GlyphIndex>;
	var kerningPairs:Array<KerningPair>;

	public var fontName:String;
	public var allGlyphs:Array<GlyphIndex>;

	public function new(i) {
		input = i;
		input.bigEndian = true;
	}

	public function read():TTF {
		var header:Header = readHeader(); // trace(header);

		var directory = readDirectory(header); // for(i in directory) trace(i);

		var tables:Array<Table> = new Array();

		var hheaData = readHheaTable(tablesHash.get("hhea"));
		tables.push(THhea(hheaData));

		var headData = readHeadTable(tablesHash.get("head"));
		tables.push(THead(headData));

		var maxpData = readMaxpTable(tablesHash.get("maxp"));
		tables.push(TMaxp(maxpData));

		var locaData = readLocaTable(tablesHash.get("loca"), headData, maxpData);
		tables.push(TLoca(locaData));

		var hmtxData = readHmtxTable(tablesHash.get("hmtx"), maxpData, hheaData);
		tables.push(THmtx(hmtxData));

		var cmapData = readCmapTable(tablesHash.get("cmap"));
		tables.push(TCmap(cmapData));

		var glyfData = readGlyfTable(tablesHash.get("glyf"), maxpData, locaData, cmapData, hmtxData);
		tables.push(TGlyf(glyfData));

		var kernData = readKernTable(tablesHash.get("kern"));
		tables.push(TKern(kernData));

		// var postData = readPostTable(tablesHash.get("post"));
		// tables.push(TPost(postData));

		var os2Data = readOS2Table(tablesHash.get("OS_2"));
		tables.push(TOS2(os2Data));

		var nameData = readNameTable(tablesHash.get("_name"));
		tables.push(TName(nameData));

		return {
			header: header,
			directory: directory,
			tables: tables
		};
	}

	function readHeader():Header {
		return {
			majorVersion: input.readUInt16(),
			minorVersion: input.readUInt16(),
			numTables: input.readUInt16(),
			searchRange: input.readUInt16(),
			entrySelector: input.readUInt16(),
			rangeShift: input.readUInt16()
		};
	}

	function readDirectory(header):Array<Entry> {
		tablesHash = new Hash();
		var directory:Array<Entry> = new Array();
		for (i in 0...header.numTables) {
			var tableId = input.readInt32();
			var bytesOutput = new haxe.io.BytesOutput();
			bytesOutput.bigEndian = true;
			bytesOutput.writeInt32(tableId);
			var bytesName = bytesOutput.getBytes();
			var tableName:String = new haxe.io.BytesInput(bytesName).readString(4);
			if (tableName == 'name')
				tableName = '_name';
			directory[i] = {
				tableId: tableId,
				tableName: tableName,
				checksum: input.readInt32(),
				offset: input.readInt32(),
				length: input.readInt32()
			};
		}
		directory.sort(sortOnOffset32);
		for (i in 0...directory.length) {
			var entry = directory[i];
			var start = entry.offset;
			var end:Int;
			if (i == directory.length - 1)
				end = start + entry.length;
			else
				end = directory[i + 1].offset;
			var bytes = input.read(end - start);
			tablesHash.set(entry.tableName.split('/').join('_'), bytes);
		}
		return directory;
	}

	function sortOnOffset32(e1, e2):Int {
		var x = e1.offset;
		var y = e2.offset;
		var result = 0;
		if (x < y)
			result = -1;
		if (x == y)
			result = 0;
		if (x > y)
			result = 1;
		return result;
	}

	function sortOnOffset16(e1, e2):Int {
		var x = e1.offset;
		var y = e2.offset;
		var result = 0;
		if (x < y)
			result = -1;
		if (x == y)
			result = 0;
		if (x > y)
			result = 1;
		return result;
	}

	// TABLES:
	// hhea (horizontal header) table
	function readHheaTable(bytes:Bytes):HheaData {
		if (bytes == null)
			throw 'no hhea table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		return {
			version: input.readInt32(),
			ascender: input.readInt16(), // FWord (F-Units Int16)
			descender: input.readInt16(), // FWord
			lineGap: input.readInt16(), // FWord
			advanceWidthMax: input.readUInt16(), // UFWord
			minLeftSideBearing: input.readInt16(), // FWord
			minRightSideBearing: input.readInt16(), // FWord
			xMaxExtent: input.readInt16(), // FWord
			caretSlopeRise: input.readInt16(),
			caretSlopeRun: input.readInt16(),
			caretOffset: input.readInt16(), // FWord
			reserved: input.read(8),
			metricDataFormat: input.readInt16(),
			numberOfHMetrics: input.readUInt16()
		}
	}

	// head (font header) table
	function readHeadTable(bytes):HeadData {
		if (bytes == null)
			throw 'no head table found';
		var i = new BytesInput(bytes);
		i.bigEndian = true;
		return {
			version: i.readInt32(),
			fontRevision: i.readInt32(),
			checkSumAdjustment: i.readInt32(),
			magicNumber: i.readInt32(), // 0x5F0F3CF5
			flags: i.readUInt16(),
			unitsPerEm: i.readUInt16(), // range from 64 to 16384
			created: i.readDouble(),
			modified: i.readDouble(),
			xMin: i.readInt16(), // FWord
			yMin: i.readInt16(), // FWord
			xMax: i.readInt16(), // FWord
			yMax: i.readInt16(), // FWord
			macStyle: i.readUInt16(),
			lowestRecPPEM: i.readUInt16(),
			fontDirectionHint: i.readInt16(),
			indexToLocFormat: i.readInt16(),
			glyphDataFormat: i.readInt16()
		};
	}

	// maxp (maximum profile) table
	function readMaxpTable(bytes:Bytes):MaxpData {
		if (bytes == null)
			throw 'no maxp table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		return {
			versionNumber: input.readInt32(),
			numGlyphs: input.readUInt16(),
			maxPoints: input.readUInt16(),
			maxContours: input.readUInt16(),
			maxComponentPoints: input.readUInt16(),
			maxComponentContours: input.readUInt16(),
			maxZones: input.readUInt16(),
			maxTwilightPoints: input.readUInt16(),
			maxStorage: input.readUInt16(),
			maxFunctionDefs: input.readUInt16(),
			maxInstructionDefs: input.readUInt16(),
			maxStackElements: input.readUInt16(),
			maxSizeOfInstructions: input.readUInt16(),
			maxComponentElements: input.readUInt16(),
			maxComponentDepth: input.readUInt16(),
		}
	}

	// loca (glyph location) table
	function readLocaTable(bytes:Bytes, head:HeadData, maxp:MaxpData):LocaData {
		if (bytes == null)
			throw 'no loca table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;

		var offsets = new Array();
		if (head.indexToLocFormat == 0)
			for (i in 0...maxp.numGlyphs + 1)
				untyped offsets[i] = input.readUInt16() * 2;
		else
			for (i in 0...maxp.numGlyphs + 1)
				untyped offsets[i] = input.readInt32();
		return {
			factor: head.indexToLocFormat == 0 ? 2 : 1,
			offsets: offsets
		};
	}

	// hmtx (horizontal metrics) table
	function readHmtxTable(bytes, maxp, hhea):Array<Metric> {
		if (bytes == null)
			throw 'no hmtx table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		var metrics:Array<Metric> = new Array();
		for (i in 0...hhea.numberOfHMetrics) {
			metrics.push({
				advanceWidth: input.readUInt16(),
				leftSideBearing: input.readInt16() // FWord
			});
		}
		var len = maxp.numGlyphs - hhea.numberOfHMetrics;
		var lastAdvanceWidth = metrics[metrics.length - 1].advanceWidth;
		for (i in 0...len) {
			metrics.push({advanceWidth: lastAdvanceWidth, leftSideBearing: input.readInt16()});
		}
		return metrics;
	}

	// glyf (glyph outline) table
	function readGlyfTable(bytes:Bytes, maxp:MaxpData, loca:LocaData, cmap, hmtx):Array<GlyfDescription> {
		if (bytes == null)
			throw 'no glyf table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		var descriptions:Array<GlyfDescription> = new Array();
		for (i in 0...maxp.numGlyphs)
			descriptions.push(readGlyf(i, input, loca.offsets[i + 1] - loca.offsets[i]));
		return descriptions;
	}

	function readGlyf(glyphIndex, input, len):GlyfDescription {
		if (len > 0) {
			var numberOfContours = input.readInt16();
			var glyphHeader = {
				numberOfContours: numberOfContours,
				xMin: input.readInt16(), // FWord
				yMin: input.readInt16(), // FWord
				xMax: input.readInt16(), // FWord
				yMax: input.readInt16() // FWord
			}
			len -= 10;
			if (numberOfContours >= 0) {
				return TGlyphSimple(glyphHeader, readGlyfSimple(numberOfContours, input, len));
			} else if (numberOfContours == -1) {
				return TGlyphComposite(glyphHeader, readGlyfComposite(input, len, glyphIndex));
			} else {
				throw 'unknown GlyfDescription';
			}
		} else {
			return TGlyphNull;
		}
		return TGlyphNull;
	}

	function readGlyfSimple(numberOfContours, input, len):GlyphSimple {
		var endPtsOfContours:Array<Int> = new Array();
		for (i in 0...numberOfContours) {
			endPtsOfContours[i] = input.readUInt16();
			len -= 2;
		}
		var count:Int = endPtsOfContours[numberOfContours - 1] + 1;

		var instructionLength = input.readUInt16();
		len -= 2;

		var instructions:Array<Int> = new Array();
		for (i in 0...instructionLength) {
			instructions[i] = input.readByte();
			len -= 1;
		}

		var flags:Array<Int> = new Array();
		var iindex:Int = 0;
		var jindex:Int = 1;
		while (true) {
			if (iindex < count) {
				flags[iindex] = input.readByte();
				len -= 1;
				if ((flags[iindex] & 0x08) != 0) {
					var repeats:Int = input.readByte();
					len -= 1;
					jindex = 1;
					while (true) {
						if (jindex < repeats + 1) {
							flags[iindex + jindex] = flags[iindex];
							jindex++;
						} else
							break;
					}
					iindex += repeats;
				}
				iindex++;
			} else
				break;
		}
		var xCoordinates:Array<Int> = new Array();
		var yCoordinates:Array<Int> = new Array();
		var x:Int = 0;
		var y:Int = 0;
		for (i in 0...count) {
			if ((flags[i] & 0x10) != 0) {
				if ((flags[i] & 0x02) != 0) {
					x += input.readByte();
					len -= 1;
				}
			} else {
				if ((flags[i] & 0x02) != 0) {
					x += -(input.readByte());
					len -= 1;
				} else {
					x += input.readInt16();
					len -= 2;
				}
			}
			xCoordinates[i] = x;
		}

		for (i in 0...count) {
			if ((flags[i] & 0x20) != 0) {
				if ((flags[i] & 0x04) != 0) {
					y += input.readByte();
					len -= 1;
				}
			} else {
				if ((flags[i] & 0x04) != 0) {
					y += -(input.readByte());
					len -= 1;
				} else {
					y += input.readInt16();
					len -= 2;
				}
			}
			yCoordinates[i] = y;
		}
		var glyphSimple:GlyphSimple = {
			endPtsOfContours: endPtsOfContours,
			flags: flags,
			instructions: instructions,
			xCoordinates: xCoordinates,
			yCoordinates: yCoordinates
		}
		input.read(len);
		return glyphSimple;
	}

	function readGlyfComposite(input, len, glyphIndex):Array<GlyphComponent> {
		var components:Array<GlyphComponent> = new Array();
		input.read(len);
		return components;
		/*
			var components:Array<GlyphComponent>=new Array();
				  var firstIndex   = 0;
				  var firstContour = 0;
			var flags = 0xFF;
				  try
				  {
			while ((flags & CFlag.MORE_COMPONENTS) != 0)
				{
					var argument1, argument2, xtranslate, ytranslate, point1, point2, xscale, yscale, scale01, scale10;
			var flags = input.readInt16();
					len-=2;
			  var glyphIndex = input.readInt16();
					trace('glyph Composite index =' +cast glyphIndex);
					len-=2;
			  if ((flags & CFlag.ARG_1_AND_2_ARE_WORDS) != 0)
			  {
				argument1 = input.readInt16();
				argument2 = input.readInt16();
						len-=4;
			  }
					else
			  {
				argument1 = input.readByte();
				argument2 = input.readByte();
						len-=2;
			  }
			  if ((flags & CFlag.ARGS_ARE_XY_VALUES) != 0)
			  {
						xtranslate = argument1;
				ytranslate = argument2;
			  }
					else
			  {
				point1 = argument1;
				point2 = argument2;
			  }

					var transform=null;
			  if ((flags & CFlag.WE_HAVE_A_SCALE) != 0)
			  {
				xscale = yscale = input.readInt16()/ 0x4000;
						transform = Transform1(xscale);
						len-=2;
			  }
					else if ((flags & CFlag.WE_HAVE_AN_X_AND_Y_SCALE) != 0)
					{
				xscale = input.readInt16()/0x4000;
				yscale = input.readInt16()/0x4000;
						transform = Transform2(xscale, yscale);
						len-=4;
			   }
					 else if ((flags & CFlag.WE_HAVE_A_TWO_BY_TWO) != 0)
					 {
				  xscale = input.readInt16()/0x4000;
				  scale01 = input.readInt16()/0x4000;
				  scale10 = input.readInt16()/0x4000;
				  yscale = input.readInt16()/ 0x4000;
							transform = Transform3(xscale, yscale, scale01, scale10);
							len-=8;
			   }

					var comp:GlyphComponent=
					{
						flags:flags,
						glyphIndex:glyphIndex,
						argument1:argument1,
						argument2:argument1,
						transform:transform
					}
			  components.push(comp);

			  var desc:GlyfDescript = descriptions[glyphindex];
			  if (desc != null)
			  {
				 firstIndex   += desc.getPointCount();
				firstContour += desc.getContourCount();
			  }
			}
			if ((flags & CFlag.WE_HAVE_INSTRUCTIONS) != 0)
			{
						var instructionLength = input.readUInt16();
						len-=2;
						var instructions:Array<Int> = new Array();
						for (i in 0...instructionLength)
						{
							instructions[i] = input.readByte();
							len-=1;
						}
			}

				//trace('composite remaining length: '+ len);
				input.read(len);
				  }
			catch (e:Dynamic)
			{
			 //throw e;
				  }
			input.read(len);
			return components;
		 */
	}

	// cmap (character code mapping) table
	function readCmapTable(bytes:Bytes):Array<CmapSubTable> {
		if (bytes == null)
			throw 'no cmap table found';
		var input = new BytesInput(bytes);
		input.bigEndian = true;

		var version = input.readUInt16();
		var numberSubtables = input.readUInt16();

		var directory:Array<CmapEntry> = new Array();
		for (i in 0...numberSubtables) {
			directory.push({
				platformId: input.readUInt16(),
				platformSpecificId: input.readUInt16(),
				offset: input.readInt32(),
			});
		}
		var subTables:Array<CmapSubTable> = new Array();
		for (i in 0...numberSubtables) {
			subTables.push(readSubTable(bytes, directory[i]));
		}
		return subTables;
	}

	function readSubTable(bytes, entry:CmapEntry):CmapSubTable {
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		input.read(entry.offset);

		var cmapFormat = input.readUInt16();
		var length = input.readUInt16();
		var language = input.readUInt16();

		var cmapHeader = {
			platformId: entry.platformId,
			platformSpecificId: entry.platformSpecificId,
			offset: entry.offset,
			format: cmapFormat,
			language: language
		}

		glyphIndexArray = new Array();
		allGlyphs = new Array();

		if (cmapFormat == 0) {
			for (j in 0...256)
				glyphIndexArray[j] = {
					charCode: j,
					index: input.readByte(),
					char: MacGlyphNames.names[j],
				};
			return Cmap0(cmapHeader, glyphIndexArray);
		} else if (cmapFormat == 4) {
			var segCount = cast input.readUInt16() / 2;
			var searchRange = input.readUInt16();
			var entrySelector = input.readUInt16();
			var rangeShift = input.readUInt16();
			var endCodes = new Array();
			var startCodes = new Array();
			var idDeltas = new Array();
			var idRangeOffsets = new Array();
			var glyphIndices = new Array();
			for (i in 0...segCount)
				endCodes.push(input.readUInt16());
			input.readUInt16();
			for (i in 0...segCount)
				startCodes.push(input.readUInt16());
			for (i in 0...segCount)
				idDeltas.push(input.readUInt16());
			for (i in 0...segCount)
				idRangeOffsets.push(input.readUInt16());
			var count = Std.int((length - (8 * segCount + 16)) / 2);
			for (i in 0...count)
				glyphIndices[i] = input.readUInt16();

			glyphIndexArray[0] = {charCode: 0, index: 0, char: String.fromCharCode(0)}; // unknown glyph (missing character)
			glyphIndexArray[1] = {charCode: 1, index: 1, char: String.fromCharCode(1)}; // null
			glyphIndexArray[2] = {charCode: 2, index: 2, char: String.fromCharCode(2)}; // carriage return
			allGlyphs.concat(glyphIndexArray);

			for (i in 0...segCount) {
				// trace('segment '+i+'/'+segCount +' =>  startCode:'+startCodes[i]+',  endCode:'+endCodes[i]+',  idDelta:'+idDeltas[i]+',  idRangeOffset:'+idRangeOffsets[i]);
				for (j in startCodes[i]...endCodes[i] + 1) {
					var index = mapCharCode(j, glyphIndices, segCount, startCodes, endCodes, idRangeOffsets, idDeltas);
					// trace('charCode: '+ j + ', char: '+ String.fromCharCode(j)+', index:'+ index);
					var glyphIndex:GlyphIndex = {
						charCode: j,
						index: index,
						char: String.fromCharCode(j)
					};
					glyphIndexArray[j] = glyphIndex;
					allGlyphs.push(glyphIndex);
				}
			}
			return Cmap4(cmapHeader, glyphIndexArray);
		} else if (cmapFormat == 6) {
			var firstCode:Int = input.readUInt16();
			var entryCount:Int = input.readUInt16();
			for (j in 0...entryCount) {
				var glyphIndex:GlyphIndex = {
					charCode: j,
					index: input.readUInt16(),
					char: MacGlyphNames.names[j]
				};
				glyphIndexArray[j] = glyphIndex;
			}
			return Cmap6(cmapHeader, glyphIndexArray, firstCode);
		} else {
			return CmapUnk(cmapHeader, bytes);
		}
	}

	function mapCharCode(charCode:Int, glyphIndices:Array<Int>, segCount:Int, startCodes:Array<Int>, endCodes:Array<Int>, idRangeOffsets:Array<Int>,
			idDeltas:Array<Int>):Int {
		try {
			for (i in 0...segCount)
				if (endCodes[i] >= charCode)
					if (startCodes[i] <= charCode)
						if (idRangeOffsets[i] > 0) {
							var index:Int = Std.int(idRangeOffsets[i] / 2 + (charCode - startCodes[i]) - (segCount - i));
							return glyphIndices[index];
						} else {
							var index:Int = Std.int((idDeltas[i] + charCode) % 65536);
							return index;
						} else
						break;
			return 0;
		} catch (e:Dynamic)
			return 0;
		return 0;
	}

	function getCharCodeFromIndex(index:Int):Int {
		for (i in 0...glyphIndexArray.length)
			if (glyphIndexArray[i] != null && glyphIndexArray[i].index == index)
				return glyphIndexArray[i].charCode;
		throw 'charcode not found for index ' + index;
	}

	// kern (kerning) table
	function readKernTable(bytes:Bytes):Array<KernSubTable> {
		if (bytes == null)
			return [];
		var input = new BytesInput(bytes);
		input.bigEndian = true;

		var version = input.readUInt16();
		var nTables = input.readUInt16();
		var tables:Array<KernSubTable> = new Array();
		for (i in 0...nTables) {
			var version = input.readUInt16();
			var length = input.readUInt16();
			var coverage = input.readUInt16();
			var _format = coverage >> 8;
			switch (_format) {
				case 0:
					var nPairs = input.readUInt16();
					var searchRange = input.readUInt16();
					var entrySelector = input.readUInt16();
					var rangeShift = input.readUInt16();
					kerningPairs = new Array();
					for (i in 0...nPairs)
						kerningPairs.push({
							left: getCharCodeFromIndex(input.readUInt16()),
							right: getCharCodeFromIndex(input.readUInt16()),
							value: input.readInt16()
						});
					tables.push(KernSub0(kerningPairs));

				case 2:
					var rowWidth = input.readUInt16();
					var leftOffsetTable = input.readUInt16();
					var rightOffsetTable = input.readUInt16();
					var array = input.readUInt16();
					var firstGlyph = input.readUInt16();
					var nGlyphs = input.readUInt16();
					var offsets = [];
					for (i in 0...nGlyphs)
						offsets.push(input.readUInt16());
					tables.push(KernSub1(offsets));
			}
		}
		return tables;
	}

	// post (glyph name and PostScript compatibility) table
	function readPostTable(bytes:Bytes):PostData {
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		var postData = {
			version: input.readInt32(),
			italicAngle: input.readInt32(),
			underlinePosition: input.readInt16(), // FWord
			underlineThickness: input.readInt16(), // FWord
			isFixedPitch: input.readInt32(),
			minMemType42: input.readInt32(),
			maxMemType42: input.readInt32(),
			minMemType1: input.readInt32(),
			maxMemType1: input.readInt32(),
			numGlyphs: 0,
			glyphNameIndex: new Array(),
			psGlyphName: new Array()
		}
		if (postData.version == 0x00020000) {
			postData.numGlyphs = input.readUInt16();
			for (i in 0...postData.numGlyphs)
				postData.glyphNameIndex[i] = input.readUInt16();
			var high = 0;
			for (i in 0...postData.numGlyphs)
				if (high < postData.glyphNameIndex[i])
					high = postData.glyphNameIndex[i];
			if (high > 257) {
				high -= 257;
				for (i in 0...high)
					postData.psGlyphName[i] = input.readString(input.readByte());
			}
		}
		return postData;
	}

	// name (name) table
	function readNameTable(bytes:Bytes):Array<NameRecord> {
		var input = new BytesInput(bytes);
		input.bigEndian = true;

		var _format = input.readUInt16(); // 0
		var count = input.readUInt16();
		var stringOffset = input.readUInt16();

		var nameRecords:Array<NameRecord> = new Array();
		for (i in 0...count) {
			nameRecords.push({
				platformId: input.readUInt16(),
				platformSpecificId: input.readUInt16(),
				languageID: input.readUInt16(),
				nameID: input.readUInt16(),
				length: input.readUInt16(),
				offset: input.readUInt16(),
				record: ""
			});
		}
		nameRecords.sort(sortOnOffset16);
		var fontNameRecord = null;
		for (i in 0...count) {
			if (nameRecords[i].nameID == 4 && (nameRecords[i].platformId == 3 || nameRecords[i].platformId == 0)) {
				fontNameRecord = nameRecords[i];
				break;
			}
		}
		if (fontNameRecord == null)
			throw 'fontNameRecord not found'
		else {
			input.read(fontNameRecord.offset);
			for (i in 0...Std.int(fontNameRecord.length / 2))
				fontNameRecord.record += String.fromCharCode(input.readUInt16());
		}
		fontName = fontNameRecord.record;
		/*
			//offsets don't always match with length and there is overlapping. for now we only search the font name (above).
			var lastOffset = -1;
			for(i in 0...count)
			{
				var nameRecord = nameRecords[i];
				var stringBuf = new StringBuf();

				if(nameRecords[i].offset != lastOffset)
				{
					lastOffset = nameRecords[i].offset;
					switch(nameRecord.platformId)
					{
						case 0, 3:// Unicode (big-endian)// Microsoft encoding, Unicode
							for (i in 0...Std.int(nameRecord.length/2))
								stringBuf.add(String.fromCharCode(input.readUInt16()));

						case 1, 2:// Macintosh encoding, ASCII// ISO encoding, ASCII
							for (i in 0...nameRecord.length)
							stringBuf.add(String.fromCharCode(input.readByte()));
					}
				}
				nameRecord.record = stringBuf.toString();
				//trace(nameRecord.record);
			}
		 */

		return nameRecords;
	}

	// 0S2 (compatibility) table
	function readOS2Table(bytes:Bytes):OS2Data {
		var input = new BytesInput(bytes);
		input.bigEndian = true;
		var os2Data = {
			version: input.readUInt16(),
			xAvgCharWidth: input.readInt16(),
			usWeightClass: input.readUInt16(),
			usWidthClass: input.readUInt16(),
			fsType: input.readInt16(),
			ySubscriptXSize: input.readInt16(),
			ySubscriptYSize: input.readInt16(),
			ySubscriptXOffset: input.readInt16(),
			ySubscriptYOffset: input.readInt16(),
			ySuperscriptXSize: input.readInt16(),
			ySuperscriptYSize: input.readInt16(),
			ySuperscriptXOffset: input.readInt16(),
			ySuperscriptYOffset: input.readInt16(),
			yStrikeoutSize: input.readInt16(),
			yStrikeoutPosition: input.readInt16(),
			sFamilyClass: input.readInt16(),

			// panose start
			bFamilyType: input.readByte(),
			bSerifStyle: input.readByte(),
			bWeight: input.readByte(),
			bProportion: input.readByte(),
			bContrast: input.readByte(),
			bStrokeVariation: input.readByte(),
			bArmStyle: input.readByte(),
			bLetterform: input.readByte(),
			bMidline: input.readByte(),
			bXHeight: input.readByte(),
			// panose end

			ulUnicodeRange1: input.readInt32(),
			ulUnicodeRange2: input.readInt32(),
			ulUnicodeRange3: input.readInt32(),
			ulUnicodeRange4: input.readInt32(),
			achVendorID: input.readInt32(),
			fsSelection: input.readInt16(),
			usFirstCharIndex: input.readUInt16(),
			usLastCharIndex: input.readUInt16(),
			sTypoAscender: input.readInt16(),
			sTypoDescender: input.readInt16(),
			sTypoLineGap: input.readInt16(),
			usWinAscent: input.readUInt16(),
			usWinDescent: input.readUInt16()
			/*
						  ulCodePageRange1 : input.readInt32(),
						  ulCodePageRange2 : input.readInt32(),

				sxHeight:-1,
						  sCapHeight:-1,
						  usDefaultChar:-1,
						  usBreakChar:-1,
						  usMaxContext:-1
			 */
		}

		/*
				  if (os2Data.version == 2)
			{
			  os2Data.sxHeight = input.readInt16();
			  os2Data.sCapHeight = input.readInt16();
			  os2Data.usDefaultChar = input.readUInt16();
			  os2Data.usBreakChar = input.readUInt16();
			  os2Data.usMaxContext = input.readUInt16();
			}
		 */
		return os2Data;
	}
}

typedef CmapEntry = {
	platformId:Int,
	platformSpecificId:Int,
	offset:Int
}
