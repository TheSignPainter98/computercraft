package server.model;

@:enum
abstract SignalState(String) {
	var OFF = 'RED';
	var ON = 'GREEN';
}
