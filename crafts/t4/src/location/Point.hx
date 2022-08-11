package location;

import cc.GPS.GPSLocation;
import haxe.ds.Option;

@:structInit
class PointImpl {
	public final x: Int;
	public final y: Int;
	public final z: Int;
	public final dimension: Dimension;
}

@:forward
abstract Point(PointImpl) from PointImpl to PointImpl {
	@:from
	public static function fromGPSLocation(raw: GPSLocation): Point {
		return {
			x: Std.int(raw.x),
			y: Std.int(raw.y),
			z: Std.int(raw.z),
			dimension: Overworld, // TODO: Get the actual dimension
		}
	}

	@:op(A + B)
	public function add(other: Point): Option<Point> {
		if (this.dimension != other.dimension)
			return None;
		return Some({
			x: this.x + other.x,
			y: this.y + other.y,
			z: this.z + other.z,
			dimension: this.dimension,
		});
	}

	@:op(A * B)
	public function mult(lambda: Float): Point {
		return {
			x: Std.int(this.x * lambda),
			y: Std.int(this.y * lambda),
			z: Std.int(this.z * lambda),
			dimension: this.dimension,
		}
	}

	public static inline function origin(dimension: Dimension): Point {
		return {
			x: 0,
			y: 0,
			z: 0,
			dimension: dimension,
		}
	}

	public static inline function worldOrigin(): Point {
		return {
			x: 0,
			y: 0,
			z: 64,
			dimension: Overworld,
		}
	}
}
