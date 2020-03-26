package truetype;

import haxe.DynamicAccess;
import truetype.GlyphOutline;
import truetype.TTFGlyphs;

using StringTools;
using Std;

class GlyphTools {
	static public function createGlyphMap(fromIndex:Int, toIndex:Int, ttfGlyphs:TTFGlyphs):GlyphMap {
		var map = new GlyphMap();
		for (index in fromIndex...toIndex + 1) {
			if (!ttfGlyphs.isGlyphSimple(index)) {
				trace('TTF Problem here: This glyph index ($index) does not seem to be of type GlyphSimple...');
				continue;
			}
			var outlines:GlyphOutlines = ttfGlyphs.getGlyphOutlines(index);
			map.set(index, outlines);
		}
		return map;
	}

	static public function glyphMapToJson(map:GlyphMap):String {
		var indexes = [];
		for (index in map.keys())
			indexes.push(index);

		indexes.sort(Reflect.compare);
        var mapObj:DynamicAccess<GlyphOutlines> = {};
    	for (index in indexes) {
                mapObj.set('$index', map.get(index));
        }

		return haxe.Json.stringify(mapObj);
    }
    
    static public function glyphMapFromJson(jsonString:String):GlyphMap {
        var mapObj:DynamicAccess<GlyphOutlines> = haxe.Json.parse(jsonString);
        trace(mapObj);
        var map = new GlyphMap();
        for (index => outlines in mapObj) {
            map.set(Std.parseInt(index), outlines);
        }
        return map;
    }
}


