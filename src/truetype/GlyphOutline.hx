package truetype;

typedef GlyphOutlinePoint = {
	c:Bool, // curve
	x:Float,
	y:Float,
};

typedef GlyphOutline = Array<GlyphOutlinePoint>;
typedef GlyphOutlines = Array<GlyphOutline>;
typedef GlyphMap = haxe.ds.IntMap<GlyphOutlines>; // Map glyphIndex to GlyphOutlines