import truetype.TrueType;
import truetype.TrueType2Svg;
import truetype.TrueType2Canvas;

class TruetypeExample {
	static public function main() {
		new TruetypeExample();
	}

	var trueTypeFont:TrueTypeFont;

	public function new() {
		var bytes = haxe.Resource.getBytes("font");
		this.trueTypeFont = new TrueTypeFont(bytes);

		for (index in 0...this.trueTypeFont.length) {
			createAndDisplayGlyph(index);
		}
	}

	function createAndDisplayGlyph(index:Int) {
		var scale = 3.0;
		var translateY = -1000;

		var glyph = trueTypeFont.readGlyph(index);
		if (glyph == null) {
			trace('Can not create glyph for index $index');
			return;
		}

		//-------------------------------------------------------------------

		#if js
		var tt2c = new TrueType2Canvas(trueTypeFont, scale, translateY);
		tt2c.fillColor = '#ccc';
		tt2c.drawStroke = true;
		var canvas = tt2c.getGlyphCanvas2(glyph);
		if (canvas != null)
			js.Browser.document.body.appendChild(canvas);

		var svg:Xml = new TrueType2Svg(trueTypeFont, scale, translateY).getGlyphSvg2(glyph);
		if (svg != null) {
			var div = js.Browser.document.createDivElement();
			div.innerHTML = svg.toString();
			var svgElement = div.firstChild;
			js.Browser.document.body.appendChild(svgElement);
		}
		#end
	}
}
