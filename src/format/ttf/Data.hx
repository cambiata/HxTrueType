/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;

typedef TTF = {
	header:Header,
	directory:Array<Entry>,
	tables:Array<Table>
}

typedef Header = {
	majorVersion:Int,
	minorVersion:Int,
	numTables:Int,
	searchRange:Int,
	entrySelector:Int,
	rangeShift:Int,
}

abstract Header_( Header ) to Header {
	public inline function new( header: Header ){
		this = header;
	}
    @:from
    static public inline 
	function fromInput( input: haxe.io.Input ): Header_ {
		return new Header_( {
			majorVersion:	input.readUInt16(),
			minorVersion:	input.readUInt16(),
			numTables:		input.readUInt16(),
			searchRange:	input.readUInt16(),
			entrySelector:	input.readUInt16(),
			rangeShift:		input.readUInt16()
		} );
    }
}
    
typedef Entry = {
	tableId:Int32,
	tableName:String,
	checksum:Int32,
	offset:Int32,
	length:Int32,
}

enum Table {
	TGlyf(descriptions:Array<GlyfDescription>);
	THmtx(metrics:Array<Metric>);
	TCmap(subtables:Array<CmapSubTable>);
	TKern(kerning:Array<KernSubTable>);
	TName(records:Array<NameRecord>);
	THead(data:HeadData);
	THhea(data:HheaData);
	TLoca(data:LocaData);
	TMaxp(data:MaxpData);
	TPost(data:PostData);
	TOS2(data:OS2Data);
	TUnkn(bytes:Bytes);
}

// GLYF
enum GlyfDescription {
	TGlyphSimple(header:GlyphHeader, data:GlyphSimple);
	TGlyphComposite(header:GlyphHeader, components:Array<GlyphComponent>);
	TGlyphNull;
}

typedef GlyphHeader = {
	numberOfContours:Int,
	xMin:Int,
	yMin:Int,
	xMax:Int,
	yMax:Int,
}

typedef GlyphSimple = {
	endPtsOfContours:Array<Int>,
	instructions:Array<Int>,
	flags:Array<Int>,
	xCoordinates:Array<Int>,
	yCoordinates:Array<Int>,
}

typedef GlyphComponent = {
	flags:Int,
	glyphIndex:Int,
	argument1:Int,
	argument2:Int,
	transform:Transform
}

enum Transform {
	Transform1(scale:Float);
	Transform2(xscale:Float, yscale:Float);
	Transform3(xscale:Float, yscale:Float, scale01:Float, scale10:Float);
}

// HMTX
typedef Metric = {
	advanceWidth:Int,
	leftSideBearing:Int
}

// CMAP
enum CmapSubTable {
	Cmap0(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>);
	Cmap2(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>, subHeaderKeys:Array<Int>, subHeaders:Array<Int>);
	Cmap4(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>);
	Cmap6(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>, firstCode:Int);
	Cmap8(header:CmapHeader, groups:Array<CmapGroup>, is32:Array<Int>);
	Cmap10(header:CmapHeader, glyphIndexArray:Array<Int>, startCharCode:Int, numChars:Int);
	Cmap12(header:CmapHeader, groups:Array<CmapGroup>);
	CmapUnk(header:CmapHeader, bytes:Bytes);
}

typedef CmapHeader = {
	platformId:Int,
	platformSpecificId:Int,
	format:Int,
	offset:Int,
	language:Int
}

typedef GlyphIndex = {
	charCode:Int,
	index:Int,
	char:String
}

typedef CmapGroup = {
	startCharCode:Int,
	endCharCode:Int,
	startGlyphCode:Int
}

// KERN
enum KernSubTable {
	KernSub0(kerningPairs:Array<KerningPair>);
	KernSub1(array:Array<Int>);
}

typedef KerningPair = {
	left:Int,
	right:Int,
	value:Int
}

// NAME
typedef NameRecord = {
	platformId:Int,
	platformSpecificId:Int,
	languageID:Int,
	nameID:Int,
	length:Int,
	offset:Int,
	record:String,
}

// HEAD
typedef HeadData = {
	version:Int32,
	fontRevision:Int32,
	checkSumAdjustment:Int32,
	magicNumber:Int32,
	flags:Int,
	unitsPerEm:Int,
	created:Float,
	modified:Float,
	xMin:Int,
	yMin:Int,
	xMax:Int,
	yMax:Int,
	macStyle:Int,
	lowestRecPPEM:Int,
	fontDirectionHint:Int,
	indexToLocFormat:Int,
	glyphDataFormat:Int
}

// head (font header) table
abstract HeadData_( HeadData ) to HeadData {
	public inline function new( headData: HeadData ){
		this = headData;
	}
    @:from
    static public inline 
	function fromBytes( bytes: Bytes ): HeadData_ {
		if( bytes == null ) throw 'no head table found';
		var i = new BytesInput( bytes );
		i.bigEndian = true;
		return new HeadData_( {
			version: 			i.readInt32(),
			fontRevision: 		i.readInt32(),
			checkSumAdjustment: i.readInt32(),
			magicNumber: 		i.readInt32(), // 0x5F0F3CF5
			flags: 				i.readUInt16(),
			unitsPerEm: 		i.readUInt16(), // range from 64 to 16384
			created: 			i.readDouble(),
			modified: 			i.readDouble(),
			xMin: 				i.readInt16(), // FWord
			yMin: 				i.readInt16(), // FWord
			xMax: 				i.readInt16(), // FWord
			yMax: 				i.readInt16(), // FWord
			macStyle: 			i.readUInt16(),
			lowestRecPPEM: 		i.readUInt16(),
			fontDirectionHint: 	i.readInt16(),
			indexToLocFormat: 	i.readInt16(),
			glyphDataFormat: 	i.readInt16()
		} );
	}
}

// HHEA
typedef HheaData = {
	version:Int32,
	ascender:Int,
	descender:Int,
	lineGap:Int,
	advanceWidthMax:Int,
	minLeftSideBearing:Int,
	minRightSideBearing:Int,
	xMaxExtent:Int,
	caretSlopeRise:Int,
	caretSlopeRun:Int,
	caretOffset:Int,
	reserved:Bytes,
	metricDataFormat:Int,
	numberOfHMetrics:Int
}

// TABLES:
// hhea (horizontal header) table
abstract HheaData_( HheaData ) to HheaData {
	public inline function new( hheaData: HheaData ){
		this = hheaData;
	}
	@:from
	static public inline 
	function fromBytes( bytes: Bytes ): HheaData_ {
		if( bytes == null ) throw 'no hhea table found';
		var i = new BytesInput(bytes);
		i.bigEndian = true;
		return new HheaData_( {
			version: 				i.readInt32(),
			ascender: 				i.readInt16(), // FWord (F-Units Int16)
			descender: 				i.readInt16(), // FWord
			lineGap: 				i.readInt16(), // FWord
			advanceWidthMax: 		i.readUInt16(), // UFWord
			minLeftSideBearing: 	i.readInt16(), // FWord
			minRightSideBearing: 	i.readInt16(), // FWord
			xMaxExtent: 			i.readInt16(), // FWord
			caretSlopeRise: 		i.readInt16(),
			caretSlopeRun: 			i.readInt16(),
			caretOffset: 			i.readInt16(), // FWord
			reserved: 				i.read(8),
			metricDataFormat: 		i.readInt16(),
			numberOfHMetrics: 		i.readUInt16()
		} );
	}
}

// LOCA
typedef LocaData = {
	offsets:Array<Int>,
	factor:Int
}

// MAXP
typedef MaxpData = {
	versionNumber:haxe.Int32,
	numGlyphs:Int,
	maxPoints:Int,
	maxContours:Int,
	maxComponentPoints:Int,
	maxComponentContours:Int,
	maxZones:Int,
	maxTwilightPoints:Int,
	maxStorage:Int,
	maxFunctionDefs:Int,
	maxInstructionDefs:Int,
	maxStackElements:Int,
	maxSizeOfInstructions:Int,
	maxComponentElements:Int,
	maxComponentDepth:Int
}

// maxp (maximum profile) table
abstract MaxpData_( MaxpData ) to MaxpData {
	public inline function new( maxpData: MaxpData ){
		this = maxpData;
	}
	@:from
	static public inline 
	function fromBytes( bytes: Bytes ): MaxpData_ {
		if( bytes == null ) throw 'no maxp table found';
		var i = new BytesInput(bytes);
		i.bigEndian = true;
		return new MaxpData_( {
			versionNumber:			i.readInt32(),
			numGlyphs: 				i.readUInt16(),
			maxPoints:				i.readUInt16(),
			maxContours:			i.readUInt16(),
			maxComponentPoints: 	i.readUInt16(),
			maxComponentContours: 	i.readUInt16(),
			maxZones: 				i.readUInt16(),
			maxTwilightPoints: 		i.readUInt16(),
			maxStorage: 			i.readUInt16(),
			maxFunctionDefs: 		i.readUInt16(),
			maxInstructionDefs: 	i.readUInt16(),
			maxStackElements: 		i.readUInt16(),
			maxSizeOfInstructions: 	i.readUInt16(),
			maxComponentElements: 	i.readUInt16(),
			maxComponentDepth: 		i.readUInt16()
		});
	}
}

// POST
typedef PostData = {
	version:Int32,
	italicAngle:Int32,
	underlinePosition:Int,
	underlineThickness:Int,
	isFixedPitch:Int32,
	minMemType42:Int32,
	maxMemType42:Int32,
	minMemType1:Int32,
	maxMemType1:Int32,
	numGlyphs:Int,
	glyphNameIndex:Array<Int>,
	psGlyphName:Array<String>
}

// OS2
typedef OS2Data = {
	version:Int,
	xAvgCharWidth:Int,
	usWeightClass:Int,
	usWidthClass:Int,
	fsType:Int,
	ySubscriptXSize:Int,
	ySubscriptYSize:Int,
	ySubscriptXOffset:Int,
	ySubscriptYOffset:Int,
	ySuperscriptXSize:Int,
	ySuperscriptYSize:Int,
	ySuperscriptXOffset:Int,
	ySuperscriptYOffset:Int,
	yStrikeoutSize:Int,
	yStrikeoutPosition:Int,
	sFamilyClass:Int,
	bFamilyType:Int,
	bSerifStyle:Int,
	bWeight:Int,
	bProportion:Int,
	bContrast:Int,
	bStrokeVariation:Int,
	bArmStyle:Int,
	bLetterform:Int,
	bMidline:Int,
	bXHeight:Int,
	ulUnicodeRange1:Int32,
	ulUnicodeRange2:Int32,
	ulUnicodeRange3:Int32,
	ulUnicodeRange4:Int32,
	achVendorID:Int32,
	fsSelection:Int,
	usFirstCharIndex:Int,
	usLastCharIndex:Int,
	sTypoAscender:Int,
	sTypoDescender:Int,
	sTypoLineGap:Int,
	usWinAscent:Int,
	usWinDescent:Int,
	/*
		ulCodePageRange1 : Int32,
		ulCodePageRange2 : Int32,

		sxHeight : Null<Int>,
		sCapHeight : Null<Int>,
		usDefaultChar : Null<Int>,
		usBreakChar : Null<Int>,
		usMaxContext : Null<Int>
	 */
}

// 0S2 (compatibility) table
abstract OS2Data_( OS2Data ) to OS2Data {
	public inline function new( oS2Data: OS2Data ){
		this = oS2Data;
	}
	@:from
	static public inline 
	function fromBytes( bytes: Bytes ): OS2Data_ {
		if( bytes == null ) throw 'no maxp table found';
		var i = new BytesInput( bytes );
		i.bigEndian = true;
		return new OS2Data_( {
			version: 				i.readUInt16(),
			xAvgCharWidth: 			i.readInt16(),
			usWeightClass: 			i.readUInt16(),
			usWidthClass: 			i.readUInt16(),
			fsType: 				i.readInt16(),
			ySubscriptXSize: 		i.readInt16(),
			ySubscriptYSize: 		i.readInt16(),
			ySubscriptXOffset: 		i.readInt16(),
			ySubscriptYOffset: 		i.readInt16(),
			ySuperscriptXSize: 		i.readInt16(),
			ySuperscriptYSize: 		i.readInt16(),
			ySuperscriptXOffset: 	i.readInt16(),
			ySuperscriptYOffset: 	i.readInt16(),
			yStrikeoutSize: 		i.readInt16(),
			yStrikeoutPosition: 	i.readInt16(),
			sFamilyClass: 			i.readInt16(),

			// panose start
			bFamilyType: 			i.readByte(),
			bSerifStyle: 			i.readByte(),
			bWeight: 				i.readByte(),
			bProportion: 			i.readByte(),
			bContrast: 				i.readByte(),
			bStrokeVariation: 		i.readByte(),
			bArmStyle: 				i.readByte(),
			bLetterform: 			i.readByte(),
			bMidline: 				i.readByte(),
			bXHeight: 				i.readByte(),
			// panose end

			ulUnicodeRange1: 		i.readInt32(),
			ulUnicodeRange2: 		i.readInt32(),
			ulUnicodeRange3: 		i.readInt32(),
			ulUnicodeRange4: 		i.readInt32(),
			achVendorID: 			i.readInt32(),
			fsSelection: 			i.readInt16(),
			usFirstCharIndex: 		i.readUInt16(),
			usLastCharIndex: 		i.readUInt16(),
			sTypoAscender: 			i.readInt16(),
			sTypoDescender: 		i.readInt16(),
			sTypoLineGap: 			i.readInt16(),
			usWinAscent: 			i.readUInt16(),
			usWinDescent: 			i.readUInt16()
			/*
						  ulCodePageRange1 : i.readInt32(),
						  ulCodePageRange2 : i.readInt32(),

				sxHeight:-1,
						  sCapHeight:-1,
						  usDefaultChar:-1,
						  usBreakChar:-1,
						  usMaxContext:-1
			 */
		} );

		/*
				  if (os2Data.version == 2)
			{
			  os2Data.sxHeight = i.readInt16();
			  os2Data.sCapHeight = i.readInt16();
			  os2Data.usDefaultChar = i.readUInt16();
			  os2Data.usBreakChar = i.readUInt16();
			  os2Data.usMaxContext = i.readUInt16();
			}
		*/
	}
}


typedef UnicodeRange = {
	start:Int,
	end:Int
}

typedef Path = {
	type:Null<Int>,
	x:Float,
	y:Float,
	cx:Null<Float>,
	cy:Null<Float>
}
