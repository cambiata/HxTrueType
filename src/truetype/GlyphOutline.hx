package truetype;

typedef GlyphOutlinePoint = {
	@:optional var c:Bool; // curve
	var x:Float;
	var y:Float;
};

typedef GlyphOutline = Array<GlyphOutlinePoint>;
typedef GlyphOutlines = Array<GlyphOutline>;
typedef GlyphMap = haxe.ds.IntMap<GlyphOutlines>; // Map glyphIndex to GlyphOutlines