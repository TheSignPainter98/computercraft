package station;

@:structInit
class StationBufferStatus {
	public final items: Map<Cargo, Int>;
	public final itemsTotal: Int;
	public final itemCapacity: Int;
	public final fluidTotal: Int;
	public final fluidCapacity: Int;
}
