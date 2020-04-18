package typedarray;

typedef DataView =
	#if js
	js.lib.DataView;
	#else
	// todo
	#end
