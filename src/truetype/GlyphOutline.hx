package truetype;


typedef GlyphInfo = {
	index:Int,
	 outlines:GlyphOutlines,
	  unitsPerEm:Int,
	   xMax:Int,
	    yMax:Int}

typedef GlyphOutlinePoint = {
	var c:Bool; // curve
	var x:Float;
	var y:Float;
};

typedef GlyphOutline = Array<GlyphOutlinePoint>;
typedef GlyphOutlines = Array<GlyphOutline>;
typedef GlyphMap = haxe.ds.IntMap<GlyphOutlines>; // Map glyphIndex to GlyphOutlines