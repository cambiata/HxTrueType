package typedarray;

#if js

typedef Float32Array = js.lib.Float32Array;

#else

import typedarray.ArrayBufferView.ArrayBufferViewBase;
import typedarray.ArrayBufferView.ArrayLike;
import typedarray.ArrayBufferView.ArrayBufferViewImplIterator;

#if cpp
private typedef ArrayType = cpp.Float32;
#else
private typedef ArrayType = Float;
#end

@:nullSafety
@:forward
#if !macro
@:build(typedarray.macro.BuildArrayBufferView.build(ArrayType))
#end
abstract Float32Array(Float32ArrayImpl)
	to Float32ArrayImpl from Float32ArrayImpl
 	to ArrayBufferView
	to ArrayLike<ArrayType>
{
	// typed filled by macro
}

@:noCompletion
@:nullSafety
class Float32ArrayImpl extends ArrayBufferViewBase {

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
	@:pure public inline function _get(i: Int): ArrayType {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		return untyped __global__.__hxcpp_memory_get_float(this.nativeBytes, p);
		#else
		return (this.buffer: haxe.io.Bytes).getFloat(p);
		#end
	}

	@:noCompletion
	public inline function _set(i: Int, v: ArrayType): ArrayType {
		#if debug
		if (i < 0 || i >= this.length) {
			throw haxe.io.Error.OutsideBounds;
		}
		#end

		var p = i * BYTES_PER_ELEMENT + this.byteOffset;

		#if cpp
		untyped __global__.__hxcpp_memory_set_float(this.nativeBytes, p, v);
		#else
		(this.buffer: haxe.io.Bytes).setFloat(p, v);
		#end
		return v;
	}

	@:pure public inline function iterator() {
		return new ArrayBufferViewImplIterator<ArrayType>(this);
	}

}

#end
