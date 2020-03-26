import haxe.Json;
import truetype.GlyphTools;
import truetype.GlyphOutline.GlyphMap;
import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import format.ttf.Data;

using Std;

class Example {

	static public function main() {
		var bytes = haxe.Resource.getBytes("font");
		var ttfGlyphs:TTFGlyphs = new TTFGlyphs(bytes);
		trace('Font name: ' + ttfGlyphs.fontName);
		trace('Nr of glyph descriptions: ' + ttfGlyphs.length);

		//-----------------------------------------------
		// Display glyphs as Canvas and SVG
		var scale:Float = 3;
        var translateY = -1000;
		for (index in 0...ttfGlyphs.length) {
			if (! ttfGlyphs.isGlyphSimple(index)) {
				trace('Glyph index $index does not seem to be defined');
				continue;						
			}
			var canvas:js.html.CanvasElement = truetype.Glyph2Canvas.getGlyphCanvas(ttfGlyphs, index, scale, translateY, '#eee', true);
            js.Browser.document.body.appendChild(canvas);
			
			var svg:Xml = truetype.Glyph2SVG.getGlyphSvg(ttfGlyphs, index, scale, translateY);
			var div = js.Browser.document.createDivElement();
			div.innerHTML = svg.toString();
			var svgElement = div.firstChild;
            js.Browser.document.body.appendChild(svgElement);
		}
    }
    
    


}

