package ;

//#if neko
import haxe.Json;
import sys.io.File;
//#end

class SaveDataPlayer {
	public var x:Int = 0;
	public var y:Int = 0;
	public function new() {
	}
}

class SaveData {
	public var player:SaveDataPlayer;

	public function new() {
		player = new SaveDataPlayer();
		player.x = 5;
		player.y = 10;
	}

	public function set(data:Dynamic):Void {
		player.x = data.player.x;
		player.y = data.player.y;
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
