package argparse;

enum ArgTypeImpl {
	Flag;
	FalseFlag;
	String(choices: Null<Array<String>>);
	Int(choices: Null<Array<Int>>);
	Float(choices: Null<Array<Float>>);
	List(type: ArgType, count: ListCount);
}

abstract ArgType(ArgTypeImpl) from ArgTypeImpl to ArgTypeImpl {
	public function defaultParser<V>(): RawArgList->ParserFragmentResult<V> {
		return switch (this) {
			case Flag: cast storeTrue;
			case FalseFlag: cast storeFalse;
			case String(_): cast storeString;
			case Int(_): cast storeInt;
			case Float(_): cast storeFloat;
			case List(_, count):
				switch (count) {
					case AtLeast(n): cast storeAtLeastNStrings(n);
					case Exactly(n): cast storeExactlyNStrings(n);
				}
		}
	}

	public function storeTrue(_): ParserFragmentResult<Bool> {
		return {
			result: Right(true),
			shift: 0,
		}
	}

	public function storeFalse(_): ParserFragmentResult<Bool> {
		return {
			result: Right(false),
			shift: 0,
		}
	}

	public function storeString(raw: RawArgList): ParserFragmentResult<String> {
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

	public function storeInt(raw: RawArgList): ParserFragmentResult<Int> {
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

	public function storeFloat(raw: RawArgList): ParserFragmentResult<Float> {
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

	public function storeAtLeastNStrings(n: Int): RawArgList->ParserFragmentResult<Array<String>> {
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

	public function storeExactlyNStrings(n: Int): RawArgList->ParserFragmentResult<Array<String>> {
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
