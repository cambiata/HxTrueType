package truetype;

typedef Fontdata = {
    final charMap:haxe.ds.IntMap<Int>;
    final glyphOutlines:haxe.ds.IntMap<Array<Array<truetype.GlyphPoint>>>;
    final glyphXMaxMap:haxe.ds.IntMap<Float>;
    final fontYMax:Float;
}