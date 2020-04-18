package typedarray;

#if js

typedef Uint32Array = js.lib.Uint32Array;

#else

import typedarray.ArrayBufferView.ArrayBufferViewBase;
import typedarray.ArrayBufferView.ArrayLike;
import typedarray.ArrayBufferView.ArrayBufferViewImplIterator;

#if (!macro && cpp)
private typedef UInt32 = cpp.UInt32;
#else
private typedef UInt32 = Int;
#end


@:nullSafety
@:forward
#if !macro
@:build(typedarray.macro.BuildArrayBufferView.build(UInt32))
#end
abstract Uint32Array(Uint32ArrayImpl)
	to Uint32ArrayImpl from Uint32ArrayImpl
 	to ArrayBufferView
	to ArrayLike<UInt32>
{
	// typed filled by macro
}

@:noCompletion
@:nullSafety
class Uint32ArrayImpl extends ArrayBufferViewBase {

	static public inline var BYTES_PER_ELEMENT : Int = 4;

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
		return untyped __global__.__hxcpp_memory_get_ui32(this.nativeBytes, p);
		#else
		return (this.buffer: haxe.io.Bytes).get(p);
		#end
	}
	
	@:noCompletion
	public inline function _set(i: Int, v: UInt32) {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		untyped __global__.__hxcpp_memory_set_ui32(this.nativeBytes, p, v);
		#else
		(this.buffer: haxe.io.Bytes).set(p, v);
		#end
		return v;
	}

	@:pure public inline function iterator() {
		return new ArrayBufferViewImplIterator<UInt32>(this);
	}

}

#end
