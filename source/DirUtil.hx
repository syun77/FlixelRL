package ;

/**
 * 方向
 */
enum Dir {
	Left;
	Up;
	Right;
	Down;
}

class DirUtil {
	public static function toString(dir:Dir):String {
		switch(dir) {
			case Dir.Left:
				return "left";
			case Dir.Up:
				return "up";
			case Dir.Right:
				return "right";
			case Dir.Down:
				return "down";
		}
	}
}
