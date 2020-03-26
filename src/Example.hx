import haxe.Json;
import truetype.GlyphTools;
import truetype.GlyphOutline.GlyphMap;
import js.html.svg.SVGElement;
import js.Browser;
import js.Browser.document;
import js.html.CanvasElement;
import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import format.ttf.Data;

using Std;

class Example {
	static public function main() {
		var bytes = haxe.Resource.getBytes("font");
		var ttfGlyphs:TTFGlyphs = new TTFGlyphs(bytes);

		//-----------------------------------------------

		var map = truetype.GlyphTools.createGlyphMap(10, 12, ttfGlyphs);
		// for(glyphIndex => outlines in map) {
		// 	trace('index: $glyphIndex - outlines: $outlines');
		// }
		var jsonStr = GlyphTools.glyphMapToJson(map);
		trace(jsonStr);
		var map2 = GlyphTools.glyphMapFromJson(jsonStr);
		trace(map2);

		trace(map.string() == map2.string());


		//-----------------------------------------------

        var scale:Float = 3;
        var translateY = -1000;

		for (index in 9...512) {
			if (! ttfGlyphs.isGlyphSimple(index)) continue;
			
			var canvas:CanvasElement = truetype.Glyph2Canvas.getGlyphCanvas(ttfGlyphs, index, scale, translateY, false);
            document.body.appendChild(canvas);
			
			var svg:Xml = truetype.Glyph2SVG.getGlyphSvg(ttfGlyphs, index, scale, translateY);
			var div = document.createDivElement();
			div.innerHTML = svg.toString();
			var svgElement = div.firstChild;
            document.body.appendChild(svgElement);
		}
    }
    
    


}

