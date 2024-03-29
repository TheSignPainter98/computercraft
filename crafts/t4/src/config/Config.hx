package config;

import cc.OS;
import cc.Settings;
import cc.FileSystem;
import haxe.Serializer;
import haxe.Unserializer;
import machine.Machine;
import events.CustomEvent.TAG_SAVE_INVALIDATED;

class ConfigImpl {
	var config_file_name: String;
	var synced_with_disk: Bool;
	var data: Map<String, Dynamic>;

	public function new(name: String) {
		config_file_name = './state-$name.bin';
		data = load(config_file_name);
	}

	public inline function invalidate() {
		synced_with_disk = false;
		OS.queueEvent(TAG_SAVE_INVALIDATED);
	}

	private function load(fname: String): Map<String, Dynamic> {
		synced_with_disk = true;

		if (!FileSystem.exists(fname))
			return new Map();

		var f = FileSystem.open(fname, OpenFileMode.Read);
		var raw = f.readAll();
		f.close();

		var unserialiser = new Unserializer(raw);
		return unserialiser.unserialize();
	}

	public function save(?force: Bool = false) {
		if (!force && synced_with_disk)
			return;

		var serialiser = new Serializer();
		serialiser.serialize(data);
		var toWrite = serialiser.toString();

		var f = FileSystem.open(config_file_name, OpenFileMode.Write);
		f.write(toWrite);
		f.close();

		synced_with_disk = true;
	}

	public inline function get<T>(key: Accessor<T>): Null<T>
		return data[key];

	public inline function set<T>(key: Accessor<T>, value: T): T {
		data[key] = value;
		invalidate();
		return value;
	}

	public inline function setDefault<T>(key: Accessor<T>, defaultValue: () -> T): T {
		final val = this.get(key);
		return if (val != null) val else set(key, defaultValue());
	}
}

@:forward
abstract Config(ConfigImpl) from ConfigImpl to ConfigImpl {
	public static final shared: Config = new Config("SHARED");

	public inline function new(machine: Machine)
		this = new ConfigImpl(machine);

	@:op([])
	public inline function get<T>(key: Accessor<T>): Null<T>
		return this.get(key);

	@:op([])
	public inline function set<T>(key: Accessor<T>, value: T): T
		return this.set(key, value);

	public inline function save(?force: Bool = false) {
		this.save();
		if (this != shared)
			shared.save();
	}
}
