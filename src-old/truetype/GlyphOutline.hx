package truetype;

typedef GlyphInfo = {
	index:Int,
	outlines:GlyphOutlines,
	unitsPerEm:Int,
	xMax:Int,
	yMax:Int
}

// typedef GlyphPoint = {
// 	var c:Bool; // curve
// 	var x:Float;
// 	var y:Float;
// };

typedef GlyphOutline = Array<GlyphPoint>;
typedef GlyphOutlines = Array<GlyphOutline>;
typedef GlyphMap = haxe.ds.IntMap<GlyphOutlines>; // Map glyphIndex to GlyphOutlines
