package ;

/**
 * フィールド管理
 **/
class Field {
	// グリッドサイズ
	public static inline var GRID_SIZE:Int = 32;

	public static function toWorldX(i:Float):Float {
		return i * GRID_SIZE + GRID_SIZE/2;
	}
	public static function toWorldY(j:Float):Float {
		return j * GRID_SIZE + GRID_SIZE/2;
	}
	public static function toChipX(x:Float):Float {
		return Math.floor((x - GRID_SIZE/2) / GRID_SIZE);
	}
	public static function toChipY(y:Float):Float {
		return Math.floor((y - GRID_SIZE/2) / GRID_SIZE);
	}

	public function new() {
	}
}
