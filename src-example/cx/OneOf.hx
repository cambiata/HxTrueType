package cx;

import haxe.ds.Either;

abstract OneOf<A, B>(Either<A, B>) from Either<A, B> to Either<A, B> {
	@:from inline static function fromA<A, B>(a:A):OneOf<A, B> {
		return Left(a);
	}

	@:from inline static function fromB<A, B>(b:B):OneOf<A, B> {
		return Right(b);
	}

	@:to inline function toA():Null<A>
		return switch (this) {
			case Left(a): a;
			default: null;
		}

	@:to inline function toB():Null<B>
		return switch (this) {
			case Right(b): b;
			default: null;
		}
}

//---------------------------------------------------------------------------
enum Either3<A, B, C> {
	TypeA(v:A);
	TypeB(v:B);
	TypeC(v:C);
}

abstract OneOf3<A, B, C>(Either3<A, B, C>) from Either3<A, B, C> to Either3<A, B, C> {
	@:from inline static function fromA<A, B, C>(v:A):OneOf3<A, B, C> {
		return TypeA(v);
	}

	@:from inline static function fromB<A, B, C>(v:B):OneOf3<A, B, C> {
		return TypeB(v);
	}

	@:from inline static function fromC<A, B, C>(v:C):OneOf3<A, B, C> {
		return TypeC(v);
	}

	@:to inline function toA():Null<A>
		return switch (this) {
			case TypeA(v): v;
			default: null;
		}

	@:to inline function toB():Null<B>
		return switch (this) {
			case TypeB(v): v;
			default: null;
		}

	@:to inline function toC():Null<C>
		return switch (this) {
			case TypeC(v): v;
			default: null;
		}
}
