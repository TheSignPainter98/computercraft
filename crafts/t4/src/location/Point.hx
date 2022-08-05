package location;

import cc.GPS.GPSLocation;
import haxe.ds.Vector;
import haxe.ValueException;

@:structInit
class PointImpl {
	public final x: Int;
	public final y: Int;
	public final z: Int;
}

abstract Point(PointImpl) from PointImpl to PointImpl {
	@:from
	public static function fromGPSLocation(raw: GPSLocation): Point {
		return Point {
			x: raw.x,
			y: raw.y,
			z: raw.z,
		}
	}

	@:op(A + B)
	public function add(other: Point): Point {
		return {
			x: this.x + other.x,
			y: this.y + other.y,
			z: this.z + other.z,
		}
	}

	@:op(A * B)
	public function mult(lambda: Int): Point {
		return {
			x: this.x * lambda,
			y: this.y * lambda,
			z: this.z * lambda,
		}
	}
}
