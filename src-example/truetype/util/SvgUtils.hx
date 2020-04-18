package truetype.util;

class SvgUtils {
    static public function getPathFromPoints(points2:Array<Array<GlyphPoint>>):String {
        var svgPath = [];
        for (outline in points2) {
            var offCurvePoint:GlyphPoint = null;
            for (i in 0...outline.length) {
                var point = outline[i];
                if (i == 0) {
                    svgPath.push('M ${point.x} ${point.y}');
                } else {
                    var prevPoint = outline[i - 1];
                    if (point.c) { // curve?
                        if (prevPoint.c) {
                            svgPath.push('L ${point.x} ${point.y}');
                        } else {
                            svgPath.push("Q " + offCurvePoint.x + " " + offCurvePoint.y + " " + point.x + " " + point.y);
                        }
                    } else {
                        offCurvePoint = outline[i];
                    }
                }
            }
        }
        return svgPath.join(' ');
    }

}