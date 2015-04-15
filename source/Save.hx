package ;

//#if neko
import haxe.Json;
import sys.io.File;
//#end

class SaveData {
	public var player_x:Int;
	public var player_y:Int;

	public function new() {
		player_x = 100;
		player_y = 400;
	}

	public function set(data:Dynamic):Void {
		player_x = data.player_x;
		player_y = data.player_y;
		trace(this);
	}
}

/**
 * セーブ管理
 **/
class Save {

//#if neko
	// セーブデータ保存先
	private static inline var PATH_SAVE = "/Users/syun/Desktop/HaxeFlixel_RogueLike/save.txt";
//#end

  /**
   * セーブする
   **/
	public static function save():Void {

		var data = new SaveData();

		var str = Json.stringify(data);
//#if neko
		sys.io.File.saveContent(PATH_SAVE, str);
//#end
	}

	public static function load():Void {
//#if neko
		var str = sys.io.File.getContent(PATH_SAVE);
//#end
		var data = Json.parse(str);
		var s = new SaveData();
		s.set(data);
	}
}
