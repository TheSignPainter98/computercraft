package periphs;

import haxe.extern.EitherType;
import lua.Table;

typedef TrainId = String;
typedef SignalId = String;
typedef StopId = String;
typedef ObserverId = String;

@:multiReturn
extern class BlockPosition {
	var x: Int;
	var y: Int;
	var z: Int;
}

// Trains

interface ScheduleItem {
	public var data: {Text: String};
	public var type: String;
}

interface ScheduleDetail {
	public var data: AnyTable;
	public var type: String;
}

@:multiReturn
extern class TrainLocation {
	var x: Float;
	var y: Float;
	var z: Float;
	var dimension: String;
}

@:multiReturn
extern class TrainStop {
	var id: String;
	var name: String;
}

interface ExpectedTrain {
	public var destination: String;
	public var scheduleName: {text: String};

	/**
		Expected number of ticks until arriving at destination. Updates infrequently.
	**/
	public var ticks: Int;

	public var train: TrainId;
}

// Signals

@:enum
abstract SignalState(Int) {
	var Red = 0;
	var Yellow = 1;
	var Green = 2;
	var Invalid = -1;
}

// Graphs

interface GraphNode {
	public var bezier: Bool;
	public var dimension: String;
	public var x: Int;
	public var y: Int;
	public var z: Int;

	/**
		Present if bezier = true
	**/
	public var axes: Null<Table<Int, Table<Int, Int>>>;

	/**
		Present if bezier = true
	**/
	public var girder: Null<Bool>;

	/**
		Present if bezier = true
	**/
	public var normals: Null<Table<Int, Table<Int, Int>>>;

	/**
		Present if bezier = true
	**/
	public var positions: Null<Table<Int, Table<Int, Int>>>;

	/**
		Present if bezier = true
	**/
	public var primary: Null<Bool>;

	/**
		Present if bezier = true
	**/
	public var starts: Null<Table<Int, Table<Int, Float>>>;
}

extern class TrainNetworkObserver {
	public function getTrains(): Table<Int, TrainId>;
	// Hacky EitherType when it's actually both
	public function getTrainSchedule(train: TrainId): Null<Table<Int, EitherType<Table<Int, ScheduleDetail>, ScheduleItem>>>;
	public function getTrainWorldPosition(train: TrainId): Null<TrainLocation>;
	public function getTrainSpeed(train: TrainId): Null<Float>;
	public function getTrainStopped(train: TrainId): Null<TrainStop>;
	public function getStops(): Table<Int, StopId>;
	public function getStopWorldPosition(stop: StopId): Null<BlockPosition>;
	public function getStopExpectedTrain(stop: StopId): Null<Table<Int, ExpectedTrain>>;
	public function getSignals(): Table<Int, SignalId>;
	public function getSignalWorldPositions(signal: SignalId): Table<Int, Table<Int, Int>>;
	public function getSignalState(signal: SignalId, toPos: Bool): Null<SignalState>;
	public function getObservers(): Table<Int, ObserverId>;
	public function getObserverWorldPosition(): Null<BlockPosition>;
	// Could be typed better
	public function getObserverFilter(): Null<AnyTable>;
	public function getGraph(): Table<Int, GraphNode>;
}
