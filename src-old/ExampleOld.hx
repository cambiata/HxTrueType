// import js.html.CanvasRenderingContext2D;
import haxe.Json;
import truetype.GlyphTools;
import truetype.GlyphOutline;
import haxe.io.BytesInput;
import truetype.TTFGlyphs;
import format.ttf.Data;

using Std;

class ExampleOld {
	static public function main() {
		new ExampleOld();
	}

	var ttfGlyphs:TTFGlyphs;

	public function new() {
		var bytes = haxe.Resource.getBytes("font");
		this.ttfGlyphs = new TTFGlyphs(bytes);
		trace('Font name: ' + ttfGlyphs.fontName);
		trace('Nr of glyph descriptions: ' + ttfGlyphs.length);

		//-----------------------------------------------
		// Display glyphs as Canvas and SVG

		var scale:Float = 3;
		var translateY = -1000;
		var testString = 'abc123';
		trace('ttfGlyphs.length: ' + ttfGlyphs.length);

		trace(ttfGlyphs.cmapSubtables.length);
		for (sub in ttfGlyphs.cmapSubtables) {
			switch sub {
				case Cmap0(header, glyphIndexArray) | Cmap4(header, glyphIndexArray):
					trace(header);					
					var map = new haxe.ds.IntMap<Int>();
					var first256 = glyphIndexArray.splice(0, 256);

					// trace(first256);
					for (item in first256){
						if (item != null && item.char != null)
						map.set(item.charCode, item.index);
					}

					var fontName 

					var a = [];
					for(code => index in map) {
						a.push('$code => $index');
					}
					var astr = a.join(', ');
					trace(astr);
					var bstr = '
					class GeorgiaTtfMap {
						static public final map:haxe.ds.IntMap<Int> = [$astr];
					}
					';

					sys.io.File.saveContent('TtfCmap_gorgia.hx', bstr);

					var s = testString.split('');
					for (char in s) {						
						var index = map.get(char.charCodeAt(0));
						trace('char $char : index $index');
					}

				default:
				
			}
		}
		for (index in 0...ttfGlyphs.length) {
			createAndDisplayGlyhpInfo(index);
		}
	}

	function createAndDisplayGlyhpInfo(index:Int) {
		var glyphInfo:GlyphInfo = try {
			ttfGlyphs.getGlyphInfo(index);
		} catch (e:Dynamic) {
			null;
		}
		if (glyphInfo == null)
			return;

		#if js
		var canvas = truetype.Glyph2Canvas.getGlyphCanvas(glyphInfo, 3, -2000, '#00a', false);
		js.Browser.document.body.appendChild(canvas);

		var svg:Xml = truetype.Glyph2SVG.getGlyphSvg(glyphInfo, 3, -2000);
		var div = js.Browser.document.createDivElement();
		div.innerHTML = svg.toString();
		var svgElement = div.firstChild;
		js.Browser.document.body.appendChild(svgElement);
		#end
	}
}
