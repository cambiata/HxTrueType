package typedarray;

#if js

typedef Int32Array = js.lib.Int32Array;

#else

import typedarray.ArrayBufferView.ArrayBufferViewBase;
import typedarray.ArrayBufferView.ArrayLike;
import typedarray.ArrayBufferView.ArrayBufferViewImplIterator;

#if (!macro && cpp)
private typedef Int32 = cpp.Int32;
#else
private typedef Int32 = Int;
#end


@:nullSafety
@:forward
#if !macro
@:build(typedarray.macro.BuildArrayBufferView.build(Int32))
#end
abstract Int32Array(Int32ArrayImpl)
	to Int32ArrayImpl from Int32ArrayImpl
 	to ArrayBufferView
	to ArrayLike<Int32>
{
	// typed filled by macro
}

@:noCompletion
@:nullSafety
class Int32ArrayImpl extends ArrayBufferViewBase {

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
		return untyped __global__.__hxcpp_memory_get_i32(this.nativeBytes, p);
		#else
		return (this.buffer: haxe.io.Bytes).get(p);
		#end
	}
	
	@:noCompletion
	public inline function _set(i: Int, v: Int32) {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		untyped __global__.__hxcpp_memory_set_i32(this.nativeBytes, p, v);
		#else
		(this.buffer: haxe.io.Bytes).set(p, v);
		#end
		return v;
	}

	@:pure public inline function iterator() {
		return new ArrayBufferViewImplIterator<Int32>(this);
	}

}

#end
