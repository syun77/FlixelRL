package ;

#if neko
import sys.io.File;
#end
import jp_2dgames.Layer2D;
import DirUtil.Dir;
import flixel.FlxG;
import haxe.Json;

/**
 * プレイヤーデータ
 **/
private class _Player {
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
 * 敵データ
 **/
private class _Enemy {
	public var x:Int = 0;
	public var y:Int = 0;
	public var id:Int = 0;
	public var dir:String = "down";
	public function new () {
	}
}
private class _Enemies {
	public var array:Array<_Enemy>;
	public function new () {
		array = new Array<_Enemy>();
	}
	// セーブ
	public function save() {
		// いったん初期化
		array = new Array<_Enemy>();

		var enemies = cast(FlxG.state, PlayState).enemies;
		var func = function(e:Enemy) {
			var e2 = new _Enemy();
			e2.x = e.xchip;
			e2.y = e.ychip;
			e2.id = e.id;
			e2.dir = "down"; // TODO:
			array.push(e2);
		}

		enemies.forEachAlive(func);
	}
	// ロード
	public function load(data:Dynamic) {
		var enemies = cast(FlxG.state, PlayState).enemies;
		// 敵を全部消す
		enemies.kill();
		enemies.revive();
		var arr:Array<_Enemy> = data.array;
		// 作り直し
		for(e2 in arr) {
			var e:Enemy = enemies.recycle();
			e.init(e2.x, e2.y, e2.id);
		}
	}
}

/**
 * マップデータ
 **/
private class _Map {
	public var width:Int = 0;
	public var height:Int = 0;
	public var data:String = "";
	public function new() {
	}
	// セーブ
	public function save() {
		var state = cast(FlxG.state, PlayState);
		var layer = state.lField;
		width = layer.width;
		height = layer.height;
		data = layer.getCsv();
	}
	// ロード
	public function load(data:Dynamic) {
		var state = cast(FlxG.state, PlayState);
		var w = data.width;
		var h = data.height;
		var layer = new Layer2D();
		layer.setCsv(w, h, data.data);
		state.setFieldLayer(layer);
	}
}

/**
 * セーブデータ
 **/
private class SaveData {
	public var player:_Player;
	public var enemies:_Enemies;
	public var map:_Map;

	public function new() {
		player = new _Player();
		enemies = new _Enemies();
		map = new _Map();
	}

	// セーブ
	public function save():Void {
		player.save();
		enemies.save();
		map.save();
	}

	// ロード
	public function load(data:Dynamic):Void {
		player.load(data.player);
		enemies.load(data.enemies);
		map.load(data.map);
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
