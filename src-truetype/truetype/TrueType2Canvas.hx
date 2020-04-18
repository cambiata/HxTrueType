package truetype;

import haxe.ds.Either;

class TrueType2Canvas extends truetype.base.TrueType2Base {
	public var drawPoints = true;
	public var drawStroke = true;

	public function getGlyphCanvas2(indexOrGlyph:cx.OneOf<Int, Glyph>):js.html.CanvasElement {
		var glyph = switch indexOrGlyph {
			case Either.Left(index):
				var glyph = trueTypeFont.readGlyph(index);
				if (glyph == null)
					throw 'Can not create glyph for index $index';
				glyph;
			case Either.Right(glyph): glyph;
		}

		var canvas:js.html.CanvasElement = js.Browser.document.createCanvasElement();
		var canvasWidth = glyph.xMax * this.pointsScale + this.ADD_TO_GLYPH_WIDTH;
		var canvasHeight = this.fontYMax * this.pointsScale + this.ADD_TO_GLYPH_HEIGHT;
		canvas.setAttribute('height', '${canvasHeight}px');
		canvas.setAttribute('width', '${canvasWidth}px');

		var ctx:js.html.CanvasRenderingContext2D = canvas.getContext2d();
		ctx.font = "16px Arial";
		ctx.fillText('${glyph.index}', 8, 20);

		switch glyph.type {
			case Simple(points2):
				ctx.fillStyle = this.fillColor;
				truetype.util.CanvasUtil.drawGlyphOnCanvasContext2D(ctx, points2, this.pointsScale, this.translateY, 0, 0, this.drawPoints, this.drawStroke);							
			case Compound(components):
				var count = 0;
				var colors = ['red', 'green', 'blue'];
				for (component in components) {
					var compIndex = component.glyphIndex;
					var compGlyph = this.trueTypeFont.readGlyph(compIndex);
					var compMatrix = component.matrix;

					switch compGlyph.type {
						case Simple(points2):
							var moveX = compMatrix.e;
							var moveY = compMatrix.f;
							if (moveX != 0 || moveY != 0)
								points2 = points2.map(points -> points.map(point -> {x: point.x + moveX, y: point.y + moveY, c: point.c}));
							this.fillColor = colors[count++];
							truetype.util.CanvasUtil.drawGlyphOnCanvasContext2D(ctx, points2, this.pointsScale, this.translateY, 0, 0, this.drawPoints, this.drawStroke);							
						case Compound(components):
							trace("Compound in compound - should this be possible? index " + compGlyph.index);
					}
				}
		}

		return canvas;
	}

	
}
