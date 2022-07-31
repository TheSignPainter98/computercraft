package config;

import cc.OS;
import cc.Settings;
import cc.FileSystem;
import haxe.Serializer;
import haxe.Unserializer;
import machine.Machine;

class ConfigImpl {
	public static final SAVE_INVALIDATED_EVENT = "save-invalidated";

	var config_file_name: String;
	var synced_with_disk: Bool;
	var data: Map<String, Dynamic>;

	public function new(machine: Machine) {
		config_file_name = './state-$machine.bin';
		data = load(config_file_name);
	}

	public function invalidate() {
		synced_with_disk = false;
		OS.queueEvent(SAVE_INVALIDATED_EVENT);
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

	public function save(?force: Bool) {
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

	public function get<T>(key: Accessor<T>): Null<T>
		return data[key];

	public function set<T>(key: Accessor<T>, value: T) {
		data[key] = value;
		save();
	}

	public function set_default<T>(key: Accessor<T>, defaultValue: T)
		if (data[key] == null)
			set(key, defaultValue);
}

@:forward
abstract Config(ConfigImpl) from ConfigImpl to ConfigImpl {
	public inline function new(machine: Machine)
		this = new ConfigImpl(machine);

	@:op([]) public inline function get<T>(key:Accessor<T>): Null<T>
		return this.get(key);

	@:op([]) public inline function set<T>(key:Accessor<T>, value: T)
		return this.set(key, value);
}
