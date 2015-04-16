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

  /**
	 * 定数を文字列に変換
   **/
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

	/**
   * 文字列を定数に変換
   **/
	public static function fromString(str:String):Dir {
		switch(str) {
			case "left":
				return Dir.Left;
			case "up":
				return Dir.Up;
			case "right":
				return Dir.Right;
			case "down":
				return Dir.Down;
			default:
				return Dir.Down;
		}
	}

	public static function fromInt(dir:Int):Dir {
		switch(dir) {
			case 0:
				return Dir.Left;
			case 1:
				return Dir.Up;
			case 2:
				return Dir.Right;
			case 3:
				return Dir.Down;
			default:
				return Dir.Down;
		}
	}
}
