import haxe.Json;
import truetype.GlyphTools;
import truetype.GlyphOutline.GlyphMap;
// import js.Browser;
// import js.Browser.document;
// import js.html.CanvasElement;
import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import format.ttf.Data;

using Std;

class Example {
	static public function main() {
		var bytes = haxe.Resource.getBytes("font");
		var ttfGlyphs:TTFGlyphs = new TTFGlyphs(bytes);
		trace('Nr of glyph descriptions: ' + ttfGlyphs.length);

		//-----------------------------------------------
		// Test glyphs to/from json
		var firstGlyph = 8;
		var lastGlyph = 12;
		var map = truetype.GlyphTools.createGlyphMap(firstGlyph, lastGlyph, ttfGlyphs);
		var jsonStr = GlyphTools.glyphMapToJson(map);
		var map2 = GlyphTools.glyphMapFromJson(jsonStr);
		trace(map.string() == map2.string());
		#if sys 
			sys.io.File.saveContent('Glyphs-$firstGlyph-to-$lastGlyph.json', jsonStr);
		#end

		//-----------------------------------------------
		// Display glyphs as Canvas and SVG
		#if js
		var scale:Float = 1;
        var translateY = -1000;
		for (index in 8...128) {
			if (! ttfGlyphs.isGlyphSimple(index)) continue;						
			var canvas:js.html.CanvasElement = truetype.Glyph2Canvas.getGlyphCanvas(ttfGlyphs, index, scale, translateY, false);
            js.Browser.document.body.appendChild(canvas);
			
			var svg:Xml = truetype.Glyph2SVG.getGlyphSvg(ttfGlyphs, index, scale, translateY);
			var div = js.Browser.document.createDivElement();
			div.innerHTML = svg.toString();
			var svgElement = div.firstChild;
            js.Browser.document.body.appendChild(svgElement);
		}
		#end
    }
    
    


}

