import truetype.util.CanvasUtil;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.html.InputElement;
import js.Browser;

class TestMetricsExample {
	static function main() {
		trace('TestMetrics');
		new TestMetrics();
	}

	var input:InputElement;
	var charMap:haxe.ds.IntMap<Int>;
	var outlines:haxe.ds.IntMap<Array<Array<truetype.GlyphPoint>>>;
	var glyphXMaxMap:haxe.ds.IntMap<Float>;
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;

	public function new() {
		this.input = cast Browser.document.querySelector('#input');
		input.oninput = onInput;
		this.canvas = cast Browser.document.querySelector('#canvas');
		this.ctx = canvas.getContext2d();
		var fontdata:truetype.Fontdata = Fontdata_PTSerif.fontdata;
		this.charMap = fontdata.charMap;
		this.outlines = fontdata.glyphOutlines;
        this.glyphXMaxMap = fontdata.glyphXMaxMap;        
        drawString('Abc123');
	}

	function onInput(e = null) {
		trace(input.value);
		drawString(input.value);
		//-----------------------------------------------
	}

	function drawString(str:String) {
		var x = 0.0;
		var scale = .1;
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
		for (c in str.split('')) {
            try {
                trace(c);
				trace(c.charCodeAt(0));
				var code = c.charCodeAt(0);
				if (code == 32) {
                    x += 2200 * scale;
					continue;
				}
				var glyphIndex = this.charMap.get(c.charCodeAt(0));
				trace(glyphIndex);
				var glyphWidth = this.glyphXMaxMap.get(glyphIndex);
				trace(glyphWidth);
				var points2:Array<Array<truetype.GlyphPoint>> = this.outlines.get(glyphIndex);
				trace(points2);
                
                this.ctx.fillStyle = '#413B80';
				CanvasUtil.drawGlyphOnCanvasContext2D(this.ctx, points2, scale, -1700, x, 0, false, false);
				x += glyphWidth;
			} catch (e:Dynamic) {
				trace(e);
			}
		}
	}
}
