package logger;

@:enum
abstract Verbosity(Int) from Int to Int {
	var Quiet = 0;
	var Normal = 1;
	var Verbose = 2;
	public static final VERBOSITIES = [Quiet, Normal, Verbose];

	@:op(A >= B)
	public static inline function gt(a: Verbosity, b: Verbosity): Bool {
		final a: Int = a;
		final b: Int = b;
		return a >= b;
	}
}
