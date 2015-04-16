package ;

#if neko
import sys.io.File;
#end
import DirUtil.Dir;
import flixel.FlxG;
import haxe.Json;

/**
 * プレイヤーデータ
 **/
class SaveDataPlayer {
	public var x:Int = 0;
	public var y:Int = 0;
	public var dir:String = "down";
	public function new() {
	}
	// セーブ
	public function save() {
		var p = cast(FlxG.state, PlayState).player;
		x = p.xchip;
		y = p.ychip;
		dir = DirUtil.toString(p.dir);
	}
	// ロード
	public function load(data:Dynamic) {
		var p = cast(FlxG.state, PlayState).player;
		var dir = DirUtil.fromString(data.dir);
		p.init(data.x, data.y, dir);
	}
}

/**
 * セーブデータ
 **/
class SaveData {
	public var player:SaveDataPlayer;

	public function new() {
		player = new SaveDataPlayer();
	}

	// セーブ
	public function save():Void {
		player.save();
	}

	// ロード
	public function load(data:Dynamic):Void {
		player.load(data.player);
	}
}

/**
 * セーブ管理
 **/
class Save {

#if neko
	// セーブデータ保存先
	private static inline var PATH_SAVE = "/Users/syun/Desktop/HaxeFlixel_RogueLike/save.txt";
#end

  /**
   * セーブする
   **/
	public static function save():Void {

		var data = new SaveData();
		data.save();

		var str = Json.stringify(data);
#if neko
		sys.io.File.saveContent(PATH_SAVE, str);
		trace("save -------------------");
		trace(data);
#end
	}

	/**
	 * ロードする
	 **/
	public static function load():Void {
		var str = "";
#if neko
		str = sys.io.File.getContent(PATH_SAVE);
		trace("load -------------------");
		trace(str);
#end
		var data = Json.parse(str);
		var s = new SaveData();
		s.load(data);
	}
}
