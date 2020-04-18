package typedarray;

#if js

typedef Uint8ClampedArray = js.lib.Uint8ClampedArray;

#else

import typedarray.ArrayBufferView.ArrayBufferViewBase;
import typedarray.ArrayBufferView.ArrayLike;
import typedarray.ArrayBufferView.ArrayBufferViewImplIterator;

#if (!macro && cpp)
private typedef UInt8 = cpp.UInt8;
#else
private typedef UInt8 = Int;
#end


@:nullSafety
@:forward
#if !macro
@:build(typedarray.macro.BuildArrayBufferView.build(UInt8))
#end
abstract Uint8ClampedArray(Uint8ClampedArrayImpl)
	to Uint8ClampedArrayImpl from Uint8ClampedArrayImpl
 	to ArrayBufferView
	to ArrayLike<UInt8>
{
	// typed filled by macro
}

@:noCompletion
@:nullSafety
class Uint8ClampedArrayImpl extends ArrayBufferViewBase {

	static public inline var BYTES_PER_ELEMENT : Int = 1;

	@:pure public inline function new(
		?length: Int,

		?buffer: ArrayBuffer,
		?byteOffset: Int,
		?byteLength: Int
	) {
		super(
			BYTES_PER_ELEMENT,
			length,
			buffer,
			byteOffset,
			byteLength
		);
	}

	@:noCompletion
	@:pure public function _get(i: Int) {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		return untyped __global__.__hxcpp_memory_get_byte(this.nativeBytes, p);
		#else
		return (this.buffer: haxe.io.Bytes).get(p);
		#end
	}
	
	@:noCompletion
	public inline function _set(i: Int, v: UInt8) {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		// clamp
		v = (v < 0 ? 0 : v) > 0xFF ? 0xFF : v;

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		untyped __global__.__hxcpp_memory_set_byte(this.nativeBytes, p, v);
		#else
		(this.buffer: haxe.io.Bytes).set(p, v);
		#end
		return v;
	}

	@:pure public inline function iterator() {
		return new ArrayBufferViewImplIterator<UInt8>(this);
	}

}

#end
