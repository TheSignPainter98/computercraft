package events;

import lua.Table;

abstract SaveInvalidatedEvent(Table<Int, Dynamic>) {}

class CustomEvent {
	public static inline var TAG_SAVE_INVALIDATED = "save-invalidated";
	public static inline var EVENT_SAVE_INVALIDATED = new Event<SaveInvalidatedEvent>(TAG_SAVE_INVALIDATED);
}
