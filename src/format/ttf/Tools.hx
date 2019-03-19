package format.ttf;
import format.ttf.Data;
import format.ttf.Constants;
class Tools 
{
	static var limit:Int;
	static var buf:StringBuf;
	public static function dumpTable(table:Table, lim:Int=-1):String
	{
		buf = new StringBuf();
		limit = lim;
		return switch(table)
		{
			case THmtx(metrics) : dumpTHmtx(metrics);
			case TCmap(subtables) : dumpTCmap(subtables);
			case TGlyf(descriptions) : dympTGlyf(descriptions);
			case TKern(kerning) : dumpTKern(kerning);
			case TName(records) : dumpTName(records);
			
			case TPost(data) : dumpTPost(data);
			case THhea(data) : dumpTHhea(data);
			case THead(data) : dumpTHead(data);
			case TMaxp(data) : dumpTMaxp(data);
			case TLoca(data) : dumpTLoca(data);
			case TOS2(data) : dumpTOS2(data);
			
			case TUnkn(bytes) : dumpTUnk(bytes);
		}
	}
	static function dumpTHmtx(metrics:Array<Metric>):String
	{
		buf.add('\n================================= hmtx table =================================\n');
		for(i in 0...metrics.length)
		{
			if(limit!=-1 && i>limit)break;
			buf.add('\nmetrics[');buf.add(i);buf.add(']: advanceWidth: ');buf.add(metrics[i].advanceWidth);buf.add(', leftSideBearing:');buf.add(metrics[i].leftSideBearing);
		}
		return buf.toString();
	}
	static function dumpTCmap(subtables:Array<CmapSubTable>):String
	{
		buf.add('================================= cmap table =================================\n');
		buf.add('Number of subtables: ');buf.add(subtables.length);buf.add("\n");
		for(i in 0...subtables.length)
		{
			var subtable = subtables[i];
			buf.add("=================================\n");
			buf.add('Subtable ');buf.add(i);buf.add('  ');buf.add(Type.enumConstructor(subtable));buf.add("\n");
			
			var header = Type.enumParameters(subtable)[0];
			var platformId:Int = header.platformId;
			var platformSpecificId:Int = header.platformSpecificId;
			buf.add('platformId: ');buf.add(platformId );buf.add(' = ' );buf.add(Type.getEnumConstructs(Platform)[platformId]);
			buf.add('\nplatformSpecificId: ');buf.add(platformSpecificId);buf.add(' = ');
			buf.add(switch(platformSpecificId)
			{
				case 0:Type.getEnumConstructs(LangUnicode)[platformSpecificId]; 
				case 1:Type.getEnumConstructs(LangMacintosh)[platformSpecificId]; 
				case 3:Type.getEnumConstructs(LangMicrosoft)[platformSpecificId]; 
			});

			buf.add('\noffset: ');buf.add(header.offset);
			buf.add('\nformat: ');buf.add(header.format);
			buf.add('\nlanguage: ');buf.add(header.language);
			buf.add("\n");
			switch(subtable)
			{
				default:
					buf.add("not supported yet\n");
					
				case Cmap0(header, glyphIndexArray): 
					for(j in 0...256)
					{
						buf.add('macintosh CharCode :');
						buf.add(j );
						buf.add(', index = ' );
						buf.add(glyphIndexArray[j].index);
						buf.add(', char: ');
						buf.add(String.fromCharCode(glyphIndexArray[j].charCode));
						buf.add("\n");
					}
						
				case Cmap4(header, glyphIndexArray): 
					for(j in 0...glyphIndexArray.length) 
						if(glyphIndexArray[j]!=null)
						{
							buf.add('unicode charCode: ');
							buf.add(j);
							buf.add(', index = ');
							buf.add(glyphIndexArray[j].index);
							buf.add(', char: ');
							buf.add(String.fromCharCode(glyphIndexArray[j].charCode));
							buf.add("\n");
						}
			}
		}
		return buf.toString();
	}
	static function dympTGlyf(descriptions:Array<GlyfDescription>):String
	{
		buf.add('\n================================= glyf table =================================\n');
		for(i in 0...descriptions.length)
		{
			if(limit!=-1 && i>limit)break;
			var desc = descriptions[i];
			buf.add('Glyph description: ');buf.add(i);buf.add('\n');
			switch(desc)
			{
				case TGlyphSimple(header, data):
					buf.add('\nheader: xMax: '); buf.add(header.xMax);
					buf.add(', yMax:'); buf.add(header.yMax);
					buf.add(', xMin:'); buf.add(header.xMin);
					buf.add(', yMin:'); buf.add(header.yMin);
					buf.add('\nendPtsOfContours:' ); buf.add(data.endPtsOfContours);
					buf.add('\ninstructions:' ); buf.add(data.instructions);
					buf.add('\nflags:' ); buf.add(data.flags);
					buf.add('\nxCoordinates:' ); buf.add(data.xCoordinates);
					buf.add('\nyCoordinates:' ); buf.add(data.yCoordinates);
						
				case TGlyphComposite(header, components):
					buf.add('\nheader: xMax: ');buf.add(header.xMax);
					buf.add(', yMax:');buf.add(header.yMax);
					buf.add(', xMin:');buf.add(header.xMin);
					buf.add(', yMin:');buf.add(header.yMin);
					buf.add('\ncomponents: ');buf.add(components);
					
				case TGlyphNull:
					buf.add('\nTGlyphNull');
			}
			buf.add('\n\n');
		}
		return buf.toString();
	}
	static function dumpTKern(kerning:Array<KernSubTable>):String
	{
		buf.add('\n================================= kern table =================================\n');
		buf.add('Number of subtables:');buf.add(kerning.length);buf.add('\n');
		var idx=0;
		for (i in 0...kerning.length)
		{
			var table = kerning[i];
			buf.add('Kerning subtable:');buf.add(i);buf.add('\n');
			switch(table)
			{
				case KernSub0(kerningPairs):
					buf.add('Format: 0');
					for ( j in 0...kerningPairs.length)
					{
						if(limit!=-1 && j>limit)break;
						buf.add('\nsubtables[');buf.add( i );	buf.add('].kerningPairs[');buf.add(j);buf.add('].left =');buf.add( kerningPairs[j].left);
						buf.add('\nsubtables[');buf.add( i );buf.add('].kerningPairs[');buf.add(j);buf.add('].right =');buf.add( kerningPairs[j].right);
						buf.add('\nsubtables[');buf.add( i );buf.add('].kerningPairs[');buf.add(j);buf.add('].value =');buf.add( kerningPairs[j].value);
					}
				case KernSub1(array):
					buf.add('KernSub1\n');
				/*rowWidth, leftClassTable,	rightClassTable,	array):
					buf.add('Format: 1');
					buf.add('subtables['+ i +'].rowWidth:'+rowWidth);
					buf.add('subtables['+ i +'].leftClassTable:'+leftClassTable);
					buf.add('subtables['+ i +'].rightClassTable:'+rightClassTable);
					buf.add('subtables['+ i +'].array:'+array);
					*/
			}
		}
		return buf.toString();
	}
	static function dumpTName(records:Array<NameRecord>):String
	{
		buf.add('\n================================= name table =================================\n');
		for(rec in records)
		{
			buf.add('platformId: ');buf.add(rec.platformId);	
			buf.add('\nplatformSpecificId: ');buf.add(rec.platformSpecificId);	
			buf.add('\nlanguageID: ');buf.add(rec.languageID);	
			buf.add('\nnameID: ');buf.add(rec.nameID);	
			buf.add('\nlength: ');buf.add(rec.length);	
			buf.add('\noffset: ');buf.add(rec.offset);	
			buf.add('\nrecord: ');buf.add(rec.record);	
			buf.add('\n\n');
		}
		return buf.toString();
	}
	static function dumpTPost(data:PostData):String
	{
		buf.add('\n================================= post table =================================\n');
		buf.add('version : ');		buf.add(data.version);
    buf.add('\nitalicAngle : ' );		buf.add(data.italicAngle);
    buf.add('\nunderlinePosition : ' );		buf.add(data.underlinePosition);
    buf.add('\nunderlineThickness : ' );		buf.add(data.underlineThickness);
    buf.add('\nisFixedPitch : ' );		buf.add(data.isFixedPitch);
		buf.add('\nminMemType42 : ' );		buf.add(data.minMemType42);
    buf.add('\nmaxMemType42 : ' );		buf.add(data.maxMemType42);
    buf.add('\nminMemType1 : ' );		buf.add(data.minMemType1);
    buf.add('\nmaxMemType1 : ' );		buf.add(data.maxMemType1);
		buf.add('\nnumGlyphs : ' );		buf.add(data.numGlyphs);
		buf.add('\n');
		
		var idx=0;
		for(i in data.glyphNameIndex)
		{
			buf.add('glyphNameIndex: ' );buf.add(idx++ );buf.add(' : ' );buf.add(i);buf.add('\n');
		}
		idx=0;
		for(i in data.psGlyphName)
		{
			buf.add('psGlyphNameIndex: ' );	buf.add( idx++ );	buf.add( ' : ');buf.add( i);buf.add('\n');
		}
		return buf.toString();
	}
	static function dumpTHhea(data:HheaData):String
	{
		buf.add('\n================================= hhea table =================================\n');
		buf.add('version: '); buf.add(data.version); 
		buf.add('\nascender: ' ); buf.add(data.ascender); 
		buf.add('\ndescender: ' ); buf.add(data.descender); 
		buf.add('\nlineGap: ' ); buf.add(data.lineGap); 
		buf.add('\nadvanceWidthMax: ' ); buf.add(data.advanceWidthMax); 
		buf.add('\nminLeftSideBearing: ' ); buf.add(data.minLeftSideBearing); 
		buf.add('\nminRightSideBearing: ' ); buf.add(data.minRightSideBearing); 
		buf.add('\nxMaxExtent: ' ); buf.add(data.xMaxExtent); 
		buf.add('\ncaretSlopeRise: ' ); buf.add(data.caretSlopeRise); 
		buf.add('\ncaretSlopeRun: ' ); buf.add(data.caretSlopeRun); 
		buf.add('\ncaretOffset: ' ); buf.add(data.caretSlopeRun); 
		buf.add('\nmetricDataFormat: ' ); buf.add( data.metricDataFormat); 
		buf.add('\nnumberOfHMetrics: ' ); buf.add(data.numberOfHMetrics); 
		return buf.toString();
	}
	static function dumpTHead(data:HeadData):String
	{
		buf.add('\n================================= head table =================================\n');
		buf.add('version: ' ); buf.add( data.version);
		buf.add('\nfontRevision : ' ); buf.add( data.fontRevision);
		buf.add('\ncheckSumAdjustment :' ); buf.add( data.checkSumAdjustment);
		buf.add('\nmagicNumber:' ); buf.add( data.magicNumber);
		buf.add('\nflags:' ); buf.add( data.flags);
		buf.add('\nunitsPerEm: ' ); buf.add( data.unitsPerEm);
		buf.add('\ncreated:' ); buf.add( data.created);
		buf.add('\nmodified:' ); buf.add( data.modified);
		buf.add('\nxMin: ' ); buf.add( data.xMin);
		buf.add('\nyMin: ' ); buf.add( data.yMin);
		buf.add('\nxMax: ' ); buf.add( data.xMax);
		buf.add('\nyMax: ' ); buf.add( data.yMax);
		buf.add('\nmacStyle: ' ); buf.add( data.indexToLocFormat);
		buf.add('\nlowestRecPPEM:' ); buf.add( data.lowestRecPPEM);
		buf.add('\nfontDirectionHint: ' ); buf.add( data.fontDirectionHint);
		buf.add('\nindexToLocFormat: ' ); buf.add( data.indexToLocFormat);
		buf.add('\nglyphDataFormat: ' ); buf.add( data.glyphDataFormat);
		return buf.toString();
	}
	static function dumpTMaxp(data:MaxpData):String
	{
		buf.add('\n================================= maxp table =================================\n');
		buf.add('versionNumber:' ); buf.add( data.versionNumber);
		buf.add('\nnumGlyphs:' ); buf.add( data.numGlyphs);
		buf.add('\nmaxPoints:' ); buf.add( data.maxPoints);
		buf.add('\nmaxContours:' ); buf.add( data.maxContours);
		buf.add('\nmaxComponentPoints:' ); buf.add( data.maxComponentPoints);
		buf.add('\nmaxComponentContours:' ); buf.add( data.maxComponentContours);
		buf.add('\nmaxZones:' ); buf.add( data.maxZones);
		buf.add('\nmaxTwilightPoints:' ); buf.add( data.maxTwilightPoints);
		buf.add('\nmaxStorage:' ); buf.add( data.maxStorage);
		buf.add('\nmaxFunctionDefs:' ); buf.add( data.maxFunctionDefs);
		buf.add('\nmaxInstructionDefs:' ); buf.add( data.maxInstructionDefs);
		buf.add('\nmaxStackElements:' ); buf.add( data.maxStackElements);
		buf.add('\nmaxSizeOfInstructions:' ); buf.add( data.maxSizeOfInstructions);
		buf.add('\nmaxComponentElements:' ); buf.add( data.maxComponentElements);
		buf.add('\nmaxComponentDepth:' ); buf.add( data.maxComponentDepth);
		return buf.toString();
	}
	static function dumpTLoca(data:LocaData):String
	{
		buf.add('\n================================= loca table =================================\n');
		buf.add('factor: ');
		buf.add(data.factor);
		buf.add('\n');
		for (i in 0...data.offsets.length) 
		{
			if(limit!=-1 && i>limit)break;
			buf.add('offsets[');buf.add(i);buf.add(']: ');buf.add(data.offsets[i]);buf.add('\n');
		}
		return buf.toString();
	}
	static function dumpTOS2(data:OS2Data):String
	{
		buf.add('\n================================= os/2 table =================================\n');
		buf.add('version: '); buf.add( data.version);
		buf.add('\nxAvgCharWidth : '); buf.add( data.xAvgCharWidth);
		buf.add('\nusWeightClass : '); buf.add( data.usWeightClass);
		buf.add('\nusWidthClass : '); buf.add( data.usWidthClass);
		buf.add('\nfsType : '); buf.add( data.fsType);
		buf.add('\nySubscriptXSize : '); buf.add( data.ySubscriptXSize);
		buf.add('\nySubscriptYSize : '); buf.add( data.ySubscriptYSize);
		buf.add('\nySubscriptXOffset : '); buf.add( data.ySubscriptXOffset);
		buf.add('\nySubscriptYOffset : '); buf.add( data.ySubscriptYOffset);
		buf.add('\nySuperscriptXSize : '); buf.add( data.ySuperscriptXSize);
		buf.add('\nySuperscriptYSize : '); buf.add( data.ySuperscriptYSize);
		buf.add('\nySuperscriptXOffset : '); buf.add( data.ySuperscriptXOffset);
		buf.add('\nySuperscriptYOffset : '); buf.add( data.ySuperscriptYOffset);
		buf.add('\nyStrikeoutSize : '); buf.add( data.yStrikeoutSize);
		buf.add('\nyStrikeoutPosition : '); buf.add( data.yStrikeoutPosition);
		buf.add('\nsFamilyClass : '); buf.add( data.sFamilyClass);
	
		buf.add('\nbFamilyType : '); buf.add( data.bFamilyType);
		buf.add('\nbSerifStyle : '); buf.add( data.bSerifStyle);
		buf.add('\nbWeight : '); buf.add( data.bWeight);
		buf.add('\nbProportion : '); buf.add( data.bProportion);
		buf.add('\nbContrast : '); buf.add( data.bContrast);
		buf.add('\nbStrokeVariation : '); buf.add( data.bStrokeVariation);
		buf.add('\nbArmStyle : '); buf.add( data.bArmStyle);
		buf.add('\nbLetterform : '); buf.add( data.bLetterform);
		buf.add('\nbMidline : '); buf.add( data.bMidline);
		buf.add('\nbXHeight : '); buf.add( data.bXHeight);
	
		buf.add('\nulUnicodeRange1 : '); buf.add( data.ulUnicodeRange1);
		buf.add('\nulUnicodeRange2 : '); buf.add( data.ulUnicodeRange2);
		buf.add('\nulUnicodeRange3 : '); buf.add( data.ulUnicodeRange3);
		buf.add('\nulUnicodeRange4 : '); buf.add( data.ulUnicodeRange4);
		buf.add('\nachVendorID : '); buf.add( data.achVendorID);
		buf.add('\nfsSelection : '); buf.add( data.fsSelection);
		buf.add('\nusFirstCharIndex : '); buf.add( data.usFirstCharIndex);
		buf.add('\nusLastCharIndex : '); buf.add( data.usLastCharIndex);
		buf.add('\nsTypoAscender : '); buf.add( data.sTypoAscender);
		buf.add('\nsTypoDescender : '); buf.add( data.sTypoDescender);
		buf.add('\nsTypoLineGap : '); buf.add( data.sTypoLineGap);
		buf.add('\nusWinAscent : '); buf.add( data.usWinAscent);
		buf.add('\nusWinDescent : '); buf.add( data.usWinDescent);
		/*
		buf.add('ulCodePageRange1 : ' + data.ulCodePageRange1+'\n'
		buf.add('ulCodePageRange2 : ' + data.ulCodePageRange2+'\n'

		buf.add('sxHeight : ' + data.sxHeight+'\n'
		buf.add('sCapHeight : ' + data.sCapHeight+'\n'
		buf.add('usDefaultChar : ' + data.usDefaultChar+'\n'
		buf.add('usBreakChar : ' + data.usBreakChar+'\n'
		buf.add('usMaxContext : ' + data.usMaxContext+'\n'
		*/
		return buf.toString();
	}
	static function dumpTUnk(bytes):String
	{
		return '\n================================= unknown table =================================\n';
	}
}
enum Platform
{
	Unicode(enc:LangUnicode);
	Macintosh(enc:LangMacintosh);
	Reserved;
	Microsoft(enc:LangMicrosoft);
}
enum LangUnicode
{
	Default;
	Version11;
	ISO10646;
	Unicode2;
}
enum LangMacintosh
{
		Roman;
		Japanese;
		TraditionalChinese;
		Korean;
		Arabic;
		Hebrew;
		Greek;
		Russian;
		RSymbol;
		Devanagari;
		Gurmukhi;
		Gujarati;
		Oriya;
		Bengali;
		Tamil;
		Telugu;
		Kannada;
		Malayalam;
		Sinhalese;
		Burmese;
		Khmer;
		Thai;
		Laotian;
		Georgian;
		Armenian;	
		SimplifiedChinese;
		Tibetan;	
		Mongolian;	
		Geez;	
		Slavic;	
		Vietnamese;
		Sindhi;
		Uninterpreted;
}
enum LangMicrosoft
{
	Unknown;
}