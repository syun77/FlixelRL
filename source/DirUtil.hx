package ;

/**
 * 方向
 */
import flixel.util.FlxPoint;
enum Dir {
	None;
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
			case Dir.None:
				return "none";
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
			case "none":
				return Dir.None;
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

	/**
	 * 指定方向に移動する
	 **/
	public static function move(dir:Dir, pt:FlxPoint):FlxPoint {
		switch(dir) {
			case Dir.Left:
				pt.x -= 1;
			case Dir.Up:
				pt.y -= 1;
			case Dir.Right:
				pt.x += 1;
			case Dir.Down:
				pt.y += 1;
			case Dir.None:
				// 何もしない
		}
		return pt;
	}

	/**
	 * 水平方向かどうか
	 **/
	public static function isHorizontal(dir:Dir):Bool {
		switch(dir) {
			case Dir.Left:
				return true;
			case Dir.Right:
				return true;
			default:
				return false;
		}
	}

	/**
	 * 垂直方向かどうか
	 **/
	public static function isVertical(dir:Dir):Bool {
		switch(dir) {
			case Dir.Up:
				return true;
			case Dir.Down:
				return true;
			default:
				return false;
		}
	}

	/**
	 * 入力キーを方向に変換する
	 * @return 入力した方向
	 **/
	public static function getInputDirection():Dir {
		if(Key.on.LEFT) {
			return Dir.Left;
		}
		else if(Key.on.RIGHT) {
			return Dir.Right;
		}
		else if(Key.on.UP) {
			return Dir.Up;
		}
		else if(Key.on.DOWN) {
			return Dir.Down;
		}
		else {
			// 入力がない
			return Dir.None;
		}
	}
}
