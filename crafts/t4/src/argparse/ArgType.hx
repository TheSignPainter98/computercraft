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
	public function defaultAction<V>(): RawArgList->ParserFragmentResult<V> {
		return switch (this) {
			case Flag: cast ArgAction.storeTrue;
			case FalseFlag: cast ArgAction.storeFalse;
			case String(_): cast ArgAction.storeString;
			case Int(_): cast ArgAction.storeInt;
			case Float(_): cast ArgAction.storeFloat;
			case List(_, count):
				switch (count) {
					case AtLeast(n): cast ArgAction.storeAtLeastNStrings(n);
					case Exactly(n): cast ArgAction.storeExactlyNStrings(n);
				}
		}
	}
}
