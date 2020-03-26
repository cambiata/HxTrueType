package truetype;

typedef GlyphOutlinePoint = {
	var c:Bool; // curve
	var x:Float;
	var y:Float;
};

typedef GlyphOutline = Array<GlyphOutlinePoint>;
typedef GlyphOutlines = Array<GlyphOutline>;
typedef GlyphMap = haxe.ds.IntMap<GlyphOutlines>; // Map glyphIndex to GlyphOutlines