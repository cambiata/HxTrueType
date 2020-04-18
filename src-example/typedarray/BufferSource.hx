package typedarray;

/**
	"The BufferSource typedef is used to represent objects that are either themselves an ArrayBuffer or which provide a view on to an ArrayBuffer."

	https://heycam.github.io/webidl/#BufferSource
**/

@:forward
abstract BufferSource(ArrayBuffer) to ArrayBuffer from ArrayBuffer {

	@:from public static inline function fromBufferView(view: ArrayBufferView) {
		return cast view.buffer;
	}

}