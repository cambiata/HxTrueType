# HxTrueType
Native Haxe TrueType parsing and rendering. WIP.

### Based on 

- Jan Flanders's hxswfml library (https://code.google.com/archive/p/hxswfml/) wich seems to be unmaintained.
- Steve Hanov's blog article "Let's read a Truetype file from scratch" - http://stevehanov.ca/blog/?id=143
- George Corney's crosstarget typedarray implementation included in the Gluon lib: https://github.com/haxiomic/gluon

### What?
- Parses .ttf files and extracts glyph outline data, charactermap data (cmap), glyph metrics - not yet kerning data, but that's planned
- Utils for rendering outline data to html canvas or native svg (without html-dom dependencies). 
- Possible to save extracted truetype data as reusable Haxe classes, for easy use of font/glyphs without the parsing overhead.

![alt text](example.png)

## TODO
- Glyph metrics
- String metrics including kerning
