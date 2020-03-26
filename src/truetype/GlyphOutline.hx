package truetype;

typedef GlyphOutlinePoint = {
	onCurve:Bool,
	x:Float,
	y:Float,
};

typedef GlyphOutline = Array<GlyphOutlinePoint>;
typedef GlyphOutlines = Array<GlyphOutline>;