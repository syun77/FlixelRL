package jp_2dgames.game;

#if neko
import sys.io.File;
#end
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.lib.Layer2D;
import jp_2dgames.game.DirUtil.Dir;
import flixel.FlxG;
import haxe.Json;

/**
 * グローバルデータ
 **/
private class _Global {
  public var floor:Int = 0;
  public var money:Int = 0;
  public var turn:Int  = 0;
  public var shop:Int  = 0;
  public function new() {}
  // セーブ
  public function save() {
    floor = Global.getFloor();
    money = Global.getMoney();
    turn  = Global.getTurn();
    shop  = Global.getShopAppearCountRaw();
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setFloor(data.floor);
    Global.setMoney(data.money);
    Global.setTurn(data.turn);
    Global.setShopAppearCount(data.shop);
  }
}

/**
 * プレイヤーデータ
 **/
private class _Player {
  public var x:Int = 0;
  public var y:Int = 0;
  public var dir:String = "down";
  public var params:Params;
  public var badstatus:String = "none";

  public function new() {
  }
  // セーブ
  public function save() {
    var p = cast(FlxG.state, PlayState).player;
    x = p.xchip;
    y = p.ychip;
    dir = DirUtil.toString(p.dir);
    params = p.params;
  }
  // ロード
  public function load(data:Dynamic) {
    var p = cast(FlxG.state, PlayState).player;
    var dir = DirUtil.fromString(data.dir);
    Global.initPlayer(p, data.x, data.y, dir, data.params);
  }
}

/**
 * イベントリ
 **/
private class _Inventory {
  public var array:Array<ItemData>;

  public function new() {
  }
  // セーブ
  public function save() {
    array = Inventory.getItemList();
  }
  // ロード
  public function load(data:Dynamic) {
    var array = new Array<ItemData>();
    for(idx in 0...data.array.length) {
      var item = data.array[idx];
      var i = new ItemData(item.id, item.param);
      i.isEquip = item.isEquip;
      array.push(i);
    }
    Global.setItemList(array);
  }
}

/**
 * 敵データ
 **/
private class _Enemy {
  public var x:Int = 0;
  public var y:Int = 0;
  public var dir:String = "down";
  public var params:Params;

  public function new() {
  }
}
private class _Enemies {
  public var array:Array<_Enemy>;

  public function new() {
    array = new Array<_Enemy>();
  }
  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_Enemy>();

    var func = function(e:Enemy) {
      var e2 = new _Enemy();
      e2.x = e.xchip;
      e2.y = e.ychip;
      e2.dir = "down"; // TODO:
      e2.params = e.params;
      array.push(e2);
    }

    Enemy.parent.forEachAlive(func);
  }
  // ロード
  public function load(data:Dynamic) {
    var enemies = Enemy.parent;
    // 敵を全部消す
    enemies.kill();
    enemies.revive();
    var arr:Array<_Enemy> = data.array;
    // 作り直し
    for(e2 in arr) {
      var e:Enemy = enemies.recycle();
      var dir = DirUtil.fromString(e2.dir);
      e.init(e2.x, e2.y, dir, e2.params);
    }
  }
}

/**
 * アイテムデータ
 **/
private class _Item {
  public var x:Int = 0;
  public var y:Int = 0;
  public var id:Int = 0;
  public var type:String = "";
  public var param:ItemExtraParam;

  public function new() {
    param = new ItemExtraParam();
  }
}
private class _Items {
  public var array:Array<_Item>;

  public function new() {
    array = new Array<_Item>();
  }
  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_Item>();

    var func = function(item:DropItem) {
      var i = new _Item();
      i.x = item.xchip;
      i.y = item.ychip;
      i.id = item.id;
      i.type = ItemUtil.toString(item.type);
      ItemExtraParam.copy(i.param, item.param);
      array.push(i);
    }

    DropItem.parent.forEachAlive(func);
  }
  // ロード
  public function load(data:Dynamic) {
    var items = DropItem.parent;
    // アイテムを全部消す
    items.kill();
    items.revive();
    var arr:Array<_Item> = data.array;
    // 作り直し
    for(i in arr) {
      var item:DropItem = items.recycle();
      var type = ItemUtil.fromString(i.type);
      item.init(i.x, i.y, type, i.id, i.param);
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
  public var global:_Global;
  public var player:_Player;
  public var inventory:_Inventory;
  public var enemies:_Enemies;
  public var items:_Items;
  public var map:_Map;

  public function new() {
    global = new _Global();
    player = new _Player();
    inventory = new _Inventory();
    enemies = new _Enemies();
    items = new _Items();
    map = new _Map();
  }

  // セーブ
  public function save():Void {
    global.save();
    player.save();
    inventory.save();
    enemies.save();
    items.save();
    map.save();
  }

  // ロード
  public function load(data:Dynamic):Void {
    global.load(data.global);
    player.load(data.player);
    inventory.load(data.inventory);
    enemies.load(data.enemies);
    items.load(data.items);
    map.load(data.map);
  }
}

/**
 * セーブ管理
 **/
class Save {

  #if neko
	// セーブデータ保存先
	private static inline var PATH_SAVE = "/Users/syun/Desktop/FlixelRL/save.txt";
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
