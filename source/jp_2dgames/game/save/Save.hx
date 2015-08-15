package jp_2dgames.game.save;

#if neko
import sys.io.File;
#end
import jp_2dgames.game.gimmick.Pit;
import jp_2dgames.game.util.CauseOfDeathMgr;
import jp_2dgames.game.item.ItemConst;
import flixel.util.FlxSave;
import jp_2dgames.game.actor.Npc;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.GuiBuyDetail;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.lib.Layer2D;
import jp_2dgames.game.util.DirUtil.Dir;
import flixel.FlxG;
import haxe.Json;

/**
 * ロード種別
 **/
enum LoadType {
  All;  // すべてロードする
  Glob; // グローバルデータのみ
}

/**
 * グローバルデータ
 **/
private class _Global {
  public var score:Int            = 0;
  public var playtime:Float       = 0;
  public var floor:Int            = 0;
  public var mapid:Int            = 0;
  public var money:Int            = 0;
  public var turn:Int             = 0;
  public var shop:Int             = 0;
  public var itemmax:Int          = 0;
  public var nightmareTurn:Int    = 0;
  public var nightmareLv:Int      = 0;
  public var nightmareAvoid:Int   = 0;
  public var nightmareDefeat:Bool = false;
  public var bgmnow:String        = "";
  public var bgmprev:String       = "";
  public var bits:Array<Bool>     = new Array<Bool>();
  public function new() {}
  // セーブ
  public function save() {
    score           = Global.getScore();
    playtime        = Global.getPlayTime();
    floor           = Global.getFloor();
    mapid           = Global.getMapID();
    money           = Global.getMoney();
    turn            = Global.getTurn();
    shop            = Global.getShopAppearCountRaw();
    itemmax         = Global.getItemMaxInventory();
    nightmareTurn   = Global.getTurnLimitNightmare();
    nightmareLv     = Global.getNightmareLv();
    nightmareAvoid  = Global.getNightmareAvoid();
    nightmareDefeat = Global.isNightmareDefeat();
    bgmnow          = Snd.getBgmNow();
    bgmprev         = Snd.getBgmPrev();
    for(i in 0...Global.BIT_MAX) {
      bits.push(Global.bitChk(i));
    }
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setScore(data.score);
    Global.setPlayTime(data.playtime);
    Global.setFloor(data.floor);
    Global.setMapID(data.mapid);
    Global.setMoney(data.money);
    Global.setTurn(data.turn);
    Global.setShopAppearCount(data.shop);
    Global.setItemMaxInventory(data.itemmax);
    Global.setTurnLimitNightmare(data.nightmareTurn);
    Global.setNightmareLv(data.nightmareLv);
    Global.setNightmareAvoid(data.nightmareAvoid);
    Global.setNightmareDefeat(data.nightmareDefeat);
    Snd.setBgmNow(data.bgmprev);
    Snd.playMusic(data.bgmnow);
    var idx = 0;
    var bits:Array<Bool> = data.bits;
    for(b in bits) {
      if(b) {
        Global.bitOn(idx);
      }
      else {
        Global.bitOff(idx);
      }
      idx++;
    }
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
    var prms:Params = new Params();
    prms.copyFromDynamic(data.params);
    Global.initPlayer(p, data.x, data.y, dir, prms);
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
      var prms = new ItemExtraParam();
      prms.copyFromDynamic(item.param);
      var i = new ItemData(item.id, prms);
      i.isEquip = item.isEquip;
      array.push(i);
    }
    Global.setItemList(array);
  }
}

/**
 * ショップ
 **/
private class _Shop {
  public var array:Array<ItemData>;

  public function new() {
  }
  // セーブ
  public function save() {
    array = GuiBuyDetail.getItemList();
  }
  // ロード
  public function load(data:Dynamic) {
    // アイテムをすべて消す
    GuiBuyDetail.delItemAll();
    for(idx in 0...data.array.length) {
      var item = data.array[idx];
      var prms = new ItemExtraParam();
      prms.copyFromDynamic(item.param);
      var i = new ItemData(item.id, prms);
      GuiBuyDetail.addItem(i);
    }
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
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(e2 in arr) {
      var e:Enemy = enemies.recycle();
      var dir = DirUtil.fromString(e2.dir);
      // エフェクト無効
      Enemy.bEffectStart = false;
      var prms:Params = new Params();
      prms.copyFromDynamic(e2.params);
      e.init(e2.x, e2.y, dir, prms);
      Enemy.bEffectStart = true;
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
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(i in arr) {
      var prm:ItemExtraParam = new ItemExtraParam();
      prm.copyFromDynamic(i.param);
      if(i.id == ItemConst.MONEY) {
        // お金
        DropItem.addMoney(i.x, i.y, prm.value);
      }
      else {
        // 通常アイテム
        DropItem.add(i.x, i.y, i.id, prm);
      }
    }
  }
}

/**
 * NPCデータ
 **/
private class _NPC {
  public var x:Int = 0;
  public var y:Int = 0;
  public var dir:String = "down";
  public var params:Params;

  public function new() {
  }
}
private class _NPCs {
  public var array:Array<_NPC>;

  public function new() {
    array = new Array<_NPC>();
  }

  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_NPC>();

    Npc.parent.forEachAlive(function(npc:Npc) {
      var npc2 = new _NPC();
      npc2.x = npc.xchip;
      npc2.y = npc.ychip;
      npc2.dir = "down"; // TODO:
      npc2.params = npc.params;
      array.push(npc2);
    });
  }

  // ロード
  public function load(data:Dynamic) {
    // NPCを全部消す
    Npc.parent.kill();
    Npc.parent.revive();
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(npc2 in arr) {
      var npc:Npc = Npc.parent.recycle();
      var dir = DirUtil.fromString(npc2.dir);
      var prms = new Params();
      prms.copyFromDynamic(npc2.params);
      npc.init(npc2.x, npc2.y, dir, prms);
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

    // ピットの状態反映
    Pit.setStateFromTurn(Global.getTurn());
  }
}

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var player:_Player;
  public var inventory:_Inventory;
  public var shop:_Shop;
  public var enemies:_Enemies;
  public var items:_Items;
  public var npcs:_NPCs;
  public var map:_Map;

  public function new() {
    global = new _Global();
    player = new _Player();
    inventory = new _Inventory();
    shop = new _Shop();
    enemies = new _Enemies();
    items = new _Items();
    npcs = new _NPCs();
    map = new _Map();
  }

  // セーブ
  public function save():Void {
    global.save();
    player.save();
    inventory.save();
    shop.save();
    enemies.save();
    items.save();
    npcs.save();
    map.save();
  }

  // ロード
  public function load(type:LoadType, data:Dynamic):Void {
    switch(type) {
      case LoadType.All:
        // すべてのデータをロードする
        global.load(data.global);
        player.load(data.player);
        inventory.load(data.inventory);
        shop.load(data.shop);
        enemies.load(data.enemies);
        items.load(data.items);
        npcs.load(data.npcs);
        map.load(data.map);

      case LoadType.Glob:
        // グローバルデータのみロードする
        global.load(data.global);
    }

    CauseOfDeathMgr.init();
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
  public static function save(bFromText:Bool, bShowLog:Bool):Void {

    var data = new SaveData();
    data.save();

    var str = Json.stringify(data);

    if(bFromText) {
      // テキストへセーブ
#if neko
    sys.io.File.saveContent(PATH_SAVE, str);
    if(bShowLog) {
      trace("save -------------------");
      trace(data);
    }
#end
    }
    else {
      // セーブデータ領域へ書き込み
      var saveutil = new FlxSave();
      saveutil.bind("SAVEDATA");
      saveutil.data.playdata = str;
      saveutil.flush();
    }
  }

  /**
	 * ロードする
	 * @param type ロード種別
	 * @param bFromText テキストから読み込む
	 * @param bShowLog ログを表示する
	 **/
  public static function load(type:LoadType, bFromText:Bool, bShowLog:Bool):Void {
    var str = "";
#if neko
    str = sys.io.File.getContent(PATH_SAVE);
    if(bShowLog) {
      trace("load -------------------");
      trace(str);
    }
#end
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(bFromText) {
      // テキストファイルからロードする
      var data = Json.parse(str);
      var s = new SaveData();
      s.load(type, data);
    }
    else {
      if(isContinue()) {
        // ロード実行
        var data = Json.parse(saveutil.data.playdata);
        var s = new SaveData();
        s.load(type, data);
      }
    }
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    saveutil.erase();
  }

  /**
   * コンティニューを選べるかどうか
   **/
  public static function isContinue():Bool {

    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.playdata == null) {
      return false;
    }

    return true;
  }
}
