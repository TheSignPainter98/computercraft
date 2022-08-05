package argparse;

abstract RawArgList(RawArgListImpl) from RawArgListImpl to RawArgListImpl {
	public var length(get, never): Int;

	private inline function get_length(): Int {
		return switch (this) {
			case Parseable(l): l.length;
			case Verbatim(l): l.length;
		}
	}

	public inline function shift(): String {
		return switch (this) {
			case Parseable(l): l.shift();
			case Verbatim(l): l.shift();
		}
	}

	public inline function unshift(s: String) {
		switch (this) {
			case Parseable(l):
				l.unshift(s);
			case Verbatim(l):
				l.unshift(s);
		}
	}

	public inline function join(s: Null<String>) {
		return switch (this) {
			case Parseable(l): l.join(s);
			case Verbatim(l): l.join(s);
		}
	}

	public inline function map(f: Array<String>->Array<String>): RawArgList {
		return switch (this) {
			case Parseable(l): Parseable(f(l));
			case Verbatim(l): Verbatim(f(l));
		}
	}
}

enum RawArgListImpl {
	Parseable(list: Array<String>);
	Verbatim(list: Array<String>);
}
