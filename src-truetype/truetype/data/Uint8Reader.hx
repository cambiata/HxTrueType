package truetype.data;

import typedarray.Uint8Array;
import typedarray.ArrayBuffer;

class Uint8Reader {
	var pos:Int;
	var data:Uint8Array;

	public function new(buffer:ArrayBuffer) {
		this.pos = 0;
		this.data = new Uint8Array(buffer);
	}

	function assert(condition:Bool, message:String = 'Assertion failed') {
		if (!condition) {
			// trace(message);
			throw message;
		}
	}

	public function seek(pos) {
		assert(pos >= 0 && pos <= this.data.length);
		var oldPos = this.pos;
		this.pos = pos;
		return oldPos;
	}

	public function tell()
		return this.pos;

	public function getUint8() {
		assert(this.pos < this.data.length);
		return this.data[this.pos++];
	}

	public function getUint16()
		return ((this.getUint8() << 8) | this.getUint8()) >>> 0;

	public function getUint32()
		return this.getInt32() >>> 0;

	public function getInt16() {
		var result = this.getUint16();
		if (result & 0x8000 != 0)
			result -= (1 << 16);
		return result;
	}

	public function getInt32() {
		return ((this.getUint8() << 24) | (this.getUint8() << 16) | (this.getUint8() << 8) | (this.getUint8()));
	}

	public function getFword() {
		return this.getInt16();
	}

	public function get2Dot14() {
		return this.getInt16() / (1 << 14);
	}

	public function getFixed() {
		return this.getInt32() / (1 << 16);
	}

	public function getString(length:Int) {
		var result = "";
		for (i in 0...length) {
			result += String.fromCharCode(this.getUint8());
		}
		return result;
	}

	public function getDate():Date {
		// TODO
		this.getUint32();
		this.getUint32();
		// var macTime = this.getUint32() * 0x10000000 + this.getUint32();
		// var utcTime = macTime * 1000 + Date.UTC(1904, 1, 1);
		return Date.now();
	}
}
