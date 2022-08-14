package argparse;

class ArgAction {
	public static function storeConst<V>(v: V): RawArgList->ParserFragmentResult<V> {
		return (raw) -> {
			return {
				result: Right(v),
				shift: 0,
			}
		}
	}

	public static function storeTrue(_): ParserFragmentResult<Bool> {
		return {
			result: Right(true),
			shift: 0,
		}
	}

	public static function storeFalse(_): ParserFragmentResult<Bool> {
		return {
			result: Right(false),
			shift: 0,
		}
	}

	public static function storeString(raw: RawArgList): ParserFragmentResult<String> {
		return {
			result: {
				switch (raw) {
					case Parseable(list):
						if (list.length == 0 || list[0].charAt(0) == '-') Left("Expected argument"); else Right(list[0]);
					case Verbatim(list):
						if (list.length == 0) Left("Expected argument"); else Right(list[0]);
				}
			},
			shift: 1,
		}
	}

	public static function storeInt(raw: RawArgList): ParserFragmentResult<Int> {
		final str = storeString(raw);
		return {
			result: switch (str.result) {
				case Left(msg): Left(msg);
				case Right(s):
					final int = Std.parseInt(s);
					if (int == null) Left('Expected integer, got $s'); else Right(int);
			},
			shift: str.shift,
		}
	}

	public static function storeFloat(raw: RawArgList): ParserFragmentResult<Float> {
		final str = storeString(raw);
		return {
			result: switch (str.result) {
				case Left(msg): Left(msg);
				case Right(s):
					final float = Std.parseFloat(s);
					if (float == null) Left('Expected float, got $s'); else Right(float);
			},
			shift: str.shift,
		}
	}

	public static function storeList(verbatim = false): RawArgList->ParserFragmentResult<Array<String>> {
		return (raw) -> {
			final toParse: RawArgList = if (verbatim) switch (raw) {
				case Parseable(l): Verbatim(l);
				case Verbatim(_): raw;
			} else raw;
			return storeAtLeastNStrings(0)(toParse);
		}
	}

	public static function storeAtLeastNStrings(n: Int): RawArgList->ParserFragmentResult<Array<String>> {
		return (raw) -> {
			switch (raw) {
				case Parseable(list):
					var limit = 0;
					for (e in list)
						if (e.charAt(0) == '-')
							break;
						else
							limit++;
					return {
						result: {
							if (limit < n)
								Left('Expected to capture at least $n arguments but could only get $limit');
							else
								Right(list.slice(0, limit));
						},
						shift: limit,
					}
				case Verbatim(list):
					if (list.length < n)
						return {
							result: Left('Expected to capture at least $n arguments but could only get ${list.length}'),
							shift: 0,
						}
					return {
						result: Right(list.slice(0, list.length)),
						shift: list.length,
					}
			}
		}
	}

	public static function storeExactlyNStrings(n: Int): RawArgList->ParserFragmentResult<Array<String>> {
		return (raw) -> {
			switch (raw) {
				case Parseable(list):
					var limit = 0;
					for (e in list)
						if (e.charAt(0) == '-')
							break;
						else
							limit++;
					if (limit < n)
						return {
							result: Left('Expected to capture $n arguments but only found $limit'),
							shift: limit,
						}
					return {
						result: Right(list.slice(0, n)),
						shift: n,
					};
				case Verbatim(list):
					if (list.length < n)
						return {
							result: Left('Expected tp capture $n arguments but only found ${list.length}'),
							shift: 0,
						}
					return {
						result: Right(list.slice(0, n)),
						shift: n,
					}
			}
		}
	}
}
