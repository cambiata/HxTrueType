package typedarray;

#if js

typedef Float64Array = js.lib.Float64Array;

#else

import typedarray.ArrayBufferView.ArrayBufferViewBase;
import typedarray.ArrayBufferView.ArrayLike;
import typedarray.ArrayBufferView.ArrayBufferViewImplIterator;

#if cpp
private typedef ArrayType = cpp.Float64;
#else
private typedef ArrayType = Float;
#end

@:nullSafety
@:forward
#if !macro
@:build(typedarray.macro.BuildArrayBufferView.build(ArrayType))
#end
abstract Float64Array(Float64ArrayImpl)
	to Float64ArrayImpl from Float64ArrayImpl
 	to ArrayBufferView
	to ArrayLike<ArrayType>
{
	// typed filled by macro
}

@:noCompletion
@:nullSafety
class Float64ArrayImpl extends ArrayBufferViewBase {

	static public inline var BYTES_PER_ELEMENT : Int = 8;

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
		return untyped __global__.__hxcpp_memory_get_double(this.nativeBytes, p);
		#else
		return (this.buffer: haxe.io.Bytes).getDouble(p);
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
		untyped __global__.__hxcpp_memory_set_double(this.nativeBytes, p, v);
		#else
		(this.buffer: haxe.io.Bytes).setDouble(p, v);
		#end
		return v;
	}

	@:pure public inline function iterator() {
		return new ArrayBufferViewImplIterator<ArrayType>(this);
	}

}

#end
