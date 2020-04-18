import truetype.GlyphPoint;
import truetype.TrueType.TrueTypeFont;
import truetype.TTFGlyphs;
import format.ttf.Data;
using StringTools;

class CreateFontMaps {

    static var LIMIT = 1000;

    static var PATH = 'src-fonts/';

	static public function main() {
		var bytes = haxe.Resource.getBytes("font");
		var ttfGlyphs = new truetype.TTFGlyphs(bytes);
        trace('Font name: ' + ttfGlyphs.fontName);
        var fontname = ttfGlyphs.fontName.replace('-', '').replace(' ', '');

        trace(bytes.length);
		var trueTypeFont:TrueTypeFont = new TrueTypeFont(bytes);
		// //-------------------------------------------------------------
        var fieldCmap = createCmap(ttfGlyphs, fontname);
        var fieldOutlines = createOutlines(trueTypeFont, fontname);
        var fieldWidths = createWidths(trueTypeFont, fontname);
        var fieldHeight = 'fontYMax: ' + trueTypeFont.yMax + ',';
        var classname = 'Fontdata_${fontname}';
        var bstr = '
class $classname {

    static public final fontdata:truetype.Fontdata = {
        // Map of char index to glyph width
        $fieldWidths
        
        $fieldHeight

        // Map of char index to glyph index
        $fieldCmap

        // Map of glyph index to glyph outlines
        $fieldOutlines
    }    
}
';
        #if sys
        sys.io.File.saveContent('$PATH$classname.hx', bstr);        
        #end
	}

    static function createWidths(trueTypeFont:TrueTypeFont, fontname:String) {
        
        var widthMap = new haxe.ds.IntMap<Float>();

        var maxIndex = trueTypeFont.length > LIMIT ? LIMIT : trueTypeFont.length;
        for (index in 0...maxIndex) {
        // for (index in 0...20) {
            
            var xMax = 0.0;
            var glyph = trueTypeFont.readGlyph(index);
			switch glyph.type {
				case Simple(points2):
                    xMax = Math.max(xMax, glyph.xMax);
                    
				case Compound(components):
					for (component in components) {
						var compIndex = component.glyphIndex;
						var compGlyph = trueTypeFont.readGlyph(compIndex);
                        xMax = Math.max(xMax, compGlyph.xMax);
					}
            }
            widthMap.set(index, xMax);
        }

        var a = [];
        for (code => index in widthMap) {
            a.push('$code => $index');
        }
        var astr = a.join(', ');        

        var classname = 'TTF_${fontname}_Metrics';
        var fieldstring = 'glyphXMaxMap: [$astr],';
        // var fieldstring2 = 'final fontYMax:Float = ' + trueTypeFont.yMax + ';';
        var bstr = '
class $classname {
    // Map of char index to glyph width
    $fieldstring

    // Font y size
    // 
}
        ';

        #if sys
        //sys.io.File.saveContent('$PATH$classname.hx', bstr);        
        #end
        return fieldstring;
    }

	static function createCmap(ttfGlyphs:TTFGlyphs, fontname:String) {
		trace(ttfGlyphs.cmapSubtables.length);
        var fieldstring = '';
		for (sub in ttfGlyphs.cmapSubtables) {
			switch sub {
				case Cmap0(header, glyphIndexArray) | Cmap4(header, glyphIndexArray):
					// trace(header);
					var map = new haxe.ds.IntMap<Int>();

					for (item in glyphIndexArray) {
						if (item != null && item.char != null && item.index != null)
							map.set(item.charCode, item.index);
					}

					var a = [];
					for (code => index in map) {
						a.push('$code => $index');
					}

					var astr = a.join(', ');
					// trace(astr);
                    var classname = 'TTF_${fontname}_Cmap';
                    fieldstring = 'charMap: [$astr],';
					var bstr = '
class $classname {
    // Map of char index to glyph index
    $fieldstring
}
					';
                    #if sys
                    //sys.io.File.saveContent('$PATH$classname.hx', bstr);
                    #end

				default:
			}
        }
        return fieldstring;
	}

    
	static function createOutlines(trueTypeFont:TrueTypeFont, fontname:String) {

        var allOutlines = new haxe.ds.IntMap<String>();
        var maxIndex = trueTypeFont.length > LIMIT ? LIMIT : trueTypeFont.length;
        // var maxIndex = 15;

        // var indexes = [1];
        for (index in 0...maxIndex) {
        // for (index in indexes) {

        // for (index in 0...20) {
            
            var allPoints2 = [];
            var glyph = trueTypeFont.readGlyph(index);
			switch glyph.type {
				case Simple(points2):
					allPoints2 =  allPoints2.concat(points2);
				case Compound(components):
					for (component in components) {
						var compIndex = component.glyphIndex;
						var compGlyph = trueTypeFont.readGlyph(compIndex);
						var compMatrix = component.matrix;

						switch compGlyph.type {
							case Simple(points2):
								var moveX = compMatrix.e;
								var moveY = compMatrix.f;
								if (moveX != 0 || moveY != 0)
									points2 = points2.map(points -> points.map(point -> {x: point.x + moveX, y: point.y + moveY, c: point.c}));

								allPoints2 = allPoints2.concat(points2);
							case Compound(components):
								trace( 'Glyph index $index: Compound in compound - should this be possible?');
						}
					}
            }
            
            allOutlines.set(index, Std.string(allPoints2));
        }
        
        var outs = [];
        for (index => outline in allOutlines) {
            outs.push('$index => $outline');
        }

        var astr = outs.join(', ');

        // trace(astr);
        
        var classname = 'TTF_${fontname}_Outlines';
        var fieldstring = 'glyphOutlines: [$astr],';
        var bstr = '
class $classname {
    // Map of glyph index to glyph outlines
    $fieldstring
}
        ';
        #if sys
        //sys.io.File.saveContent('$PATH$classname.hx', bstr);
        #end

        return fieldstring;
    }
}
