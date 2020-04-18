package typedarray;

#if js

typedef ArrayBufferView = js.lib.ArrayBufferView;

#else

interface ArrayBufferView {
	var buffer (default, null): ArrayBuffer;
	var byteOffset (default, null): Int;
	var byteLength (default, null): Int;
	#if cpp
	function toCPointer(): cpp.Star<cpp.UInt8>;
	#end
}

// internal implementation and types below

@:noCompletion
typedef ArrayLike<T> = {
	var length (default, null): Int;
	function iterator(): Iterator<T>;
};

@:noCompletion
@:nullSafety
class ArrayBufferViewBase implements ArrayBufferView {

	public final buffer: ArrayBuffer;
	public final byteOffset: Int;
	public final byteLength: Int;

	public final BYTES_PER_ELEMENT_: Int;
	public var length (default, null): Int;

	var nativeBytes (get, never): haxe.io.BytesData;

	/**
		Call as either
		- (length: Int)
		- (arrayBufferView: ArrayBufferView)
		- (buffer: ArrayBuffer, byteOffset: Int, byteLength: Int)
	**/
	function new(
		BYTES_PER_ELEMENT: Int,

		?length: Int,

		?buffer: ArrayBuffer,
		?byteOffset: Int,
		?byteLength: Int
	) {
		this.BYTES_PER_ELEMENT_ = BYTES_PER_ELEMENT;

		if (length != null) {
			this.buffer = new ArrayBuffer(length * BYTES_PER_ELEMENT);
			this.byteOffset = 0;
			this.byteLength = this.buffer.byteLength;
		}

		else if (buffer != null) {
			this.buffer = buffer;
			this.byteOffset = byteOffset != null ? byteOffset : 0;
			this.byteLength = byteLength != null ? byteLength : buffer.byteLength;
		}

		else {
			this.buffer = new ArrayBuffer(0);
			this.byteOffset = 0;
			this.byteLength = 0;
		}

		// power of two of 3 byte number
		var lengthShift = 
			((1 << 3 & BYTES_PER_ELEMENT) >> 3) * 3 +
			((1 << 2 & BYTES_PER_ELEMENT) >> 2) * 2 +
			((1 << 1 & BYTES_PER_ELEMENT) >> 1)
		;

		this.length = this.byteLength >> lengthShift;

		// validate
		#if debug
		if (this.byteLength % BYTES_PER_ELEMENT != 0) {
			throw haxe.io.Error.Custom('byte length of should be a multiple of ${BYTES_PER_ELEMENT}');
		}
		#end
	}
	
	#if cpp
	@:pure
	public inline function toCPointer(): cpp.Star<cpp.UInt8> {
		return cast cpp.NativeArray.address(this.nativeBytes, this.byteOffset).raw;
	}
	#end

	inline function get_nativeBytes() {
		return (this.buffer: haxe.io.Bytes).getData();
	}

}

@:noCompletion
@:generic
class ArrayBufferViewImplIterator<T> {

	var a: {
		var length (default, null): Int;
		function _get(i: Int): T;
		function _set(i: Int, v: T): T;
	};
	var i: Int = 0;

	public inline function new(array) {
		this.a = array;
	}

	public inline function hasNext(): Bool {
		return i < (this.a.length);
	}

	public inline function next(): T {
		return a._get(i++);
	}
	
}

#end
