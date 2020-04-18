package truetype.base;

class TrueType2Base {
	final ADD_TO_GLYPH_WIDTH = 5;
	final ADD_TO_GLYPH_HEIGHT = 100;
	var trueTypeFont:TrueTypeFont;
	var displayScale:Float;
	var translateY:Float;
	var unitsPerEm:Float;
	var fontYMax:Float;
	var pointsScale:Float;

	public var fillColor:String;

	public function new(trueTypeFont:TrueTypeFont, displayScale = .5, translateY = -1000) {
		this.trueTypeFont = trueTypeFont;
		this.displayScale = displayScale;
		this.translateY = translateY;
		this.fillColor = "#4a4ad1";
		this.unitsPerEm = this.trueTypeFont.unitsPerEm;
		this.fontYMax = this.trueTypeFont.yMax;
		this.pointsScale = (64 / this.unitsPerEm) * this.displayScale;
	}
}
