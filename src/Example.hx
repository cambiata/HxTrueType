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

