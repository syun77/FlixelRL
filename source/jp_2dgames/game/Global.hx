package jp_2dgames.game;

import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.item.ItemConst;
import flixel.util.FlxRandom;
import openfl.Assets;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.util.DirUtil.Dir;
import jp_2dgames.lib.TextUtil;

/**
 * グローバルデータ
 **/
class Global {

  /**
   * 初期化
   **/
  public static function init():Void {
    _floor = 1;
    _mapid = 0;
    _money = 0;
    _items = new Array<ItemData>();
    _nCursorInventory = 0;
    _itemMaxInventory = Inventory.ITEM_MAX_FIRST;
    _bInitPlayer = true;
    _params = new Params();
    _shopAppearCount = 0;
    _turnLimitNightmare = NightmareMgr.getTurnLimit();
    _nightmareLv = 1;
    _nightmareAvoid = 0;
    _nightmareDefeat = false;
  }

  // フロア数
  private static var _floor:Int = 1;

  /**
	 * フロア数の取得
	 **/
  public static function getFloor():Int {
    return _floor;
  }
  public static function setFloor(v:Int):Void {
    _floor = v;
  }

  /**
   * 参照しているマップの番号
   **/
  private static var _mapid:Int = 0;
  public static function getMapID():Int {
    return _mapid;
  }
  public static function setMapID(v:Int):Void {
    _mapid = v;
  }

  /**
   * 現在のフロアのマップデータのパスを取得する
   **/
  public static function getFloorMap():String {
    _mapid = _floor;
    if(_nightmareDefeat) {
      // ナイトメアを倒している
      _mapid = 500;
    }
    var map = TextUtil.fillZero(_mapid, 3);
    return 'assets/levels/${map}.tmx';
  }

  /**
	 * 次のフロアに進む
	 **/
  public static function nextFloor():Void {
    _floor++;
    // TODO: 最後まで進んだら最初に戻る
    var path = getFloorMap();
    if(Assets.exists(path, TEXT) == false) {
      _floor = 1;
    }
  }

  /**
   * 1つ前のフロアに戻る
   **/
  public static function backFloor():Void {
    _floor--;
    if(_floor < 1) {
      for(i in 0...100) {
        _floor = 100 - i;
        var path = getFloorMap();
        if(Assets.exists(path, TEXT)) {
          break;
        }
      }
    }
  }

  // 所持金
  private static var _money:Int = 0;
  public static function getMoney():Int {
    return _money;
  }
  public static function setMoney(v:Int):Void {
    _money = v;
  }
  public static function addMoney(v:Int):Int {
    _money += v;
    return _money;
  }
  public static function useMoney(v:Int):Int {
    _money -= v;
    if(_money < 0) {
      _money = 0;
    }
    return _money;
  }

  // アイテムデータ
  private static var _items:Array<ItemData> = new Array<ItemData>();
  /**
	 * アイテムデータを設定する
	 **/
  public static function setItemList(items:Array<ItemData>=null):Void {
    if(items == null) {
      // グローバルデータにあるアイテムデータを使う
      items = _items;
      if(_items.length == 0 && getFloor() == 1) {
        // りんごを持たせる
        var param = new ItemExtraParam();
        items.push(new ItemData(ItemConst.FOOD1, param));
      }
    }
    else {
      // 外部のデータを使う
      _items = items;
    }
    Inventory.setItemList(items, _nCursorInventory, _itemMaxInventory);
  }

  /**
   * 指定のアイテムを所持しているかどうか
   **/
  public static function hasItem(itemid:Int):Bool {
    for(item in _items) {
      if(item.id == itemid) {
        // 所持している
        return true;
      }
    }

    // 所持していない
    return false;
  }

  // インベントリのカーソル位置
  private static var _nCursorInventory:Int = 0;
  public static function setCursorInventory(v:Int):Void {
    _nCursorInventory = v;
  }

  // インベントリに格納可能な最大アイテム数
  private static var _itemMaxInventory:Int = Inventory.ITEM_MAX_FIRST;
  public static function getItemMaxInventory():Int {
    return _itemMaxInventory;
  }
  public static function setItemMaxInventory(v:Int):Void {
    _itemMaxInventory = v;
  }
  // アイテム所持最大数を増やす
  // @return 増えた数
  public static function addItemMaxInventory(v:Int):Int {
    var ret = Inventory.instance.addItemMax(v);
    setItemMaxInventory(Inventory.instance.getItemMax());
    return ret;
  }

  // プレイヤーのデータを初期化するかどうか
  private static var _bInitPlayer = true;
  // プレイヤーステータス
  private static var _params:Params = new Params();
  public static function initPlayer(player:Player, x:Int, y:Int, dir:Dir, params:Params = null):Void {
    if(params == null) {
      // グローバルデータにあるパラメータを使う
      params = _params;
    }
    else {
      // 外部のデータを使う
      _params = params;
    }

    // 初期化
    player.init(x, y, dir, params, _bInitPlayer);

    // 初回の初期化終わり
    _bInitPlayer = false;
  }

  // ターン数
  private static var _turnCount:Int = 0;
  // ターン数を取得する
  public static function getTurn():Int {
    return _turnCount;
  }
  // ターン数を設定する
  public static function setTurn(v:Int):Void {
    _turnCount = v;
  }
  // 次のターンに進める
  public static function nextTurn():Int {
    _turnCount++;
    return _turnCount;
  }
  // ターンを初期化する
  public static function initTurn():Void {
    _turnCount = 0;
  }

  // ナイトメア出現までのターン数
  private static var _turnLimitNightmare:Int = 0;
  public static function getTurnLimitNightmare():Int {
    return _turnLimitNightmare;
  }
  public static function setTurnLimitNightmare(v:Int):Void {
    _turnLimitNightmare = v;
  }
  // ナイトメアレベル
  private static var _nightmareLv:Int = 1;
  public static function getNightmareLv():Int {
    return _nightmareLv;
  }
  public static function setNightmareLv(v:Int):Void {
    _nightmareLv = v;
  }
  // ナイトメアを無視して次の階に進んだ回数
  private static var _nightmareAvoid:Int = 0;
  public static function getNightmareAvoid():Int {
    return _nightmareAvoid;
  }
  public static function setNightmareAvoid(v:Int):Void {
    _nightmareAvoid = v;
  }
  // ナイトメアを倒したかどうかフラグ
  private static var _nightmareDefeat:Bool = false;
  public static function isNightmareDefeat():Bool {
    return _nightmareDefeat;
  }
  public static function setNightmareDefeat(v:Bool):Void {
    _nightmareDefeat = v;
  }

  // ショップ出現カウント
  private static var _shopAppearCount:Int = 0;
  public static function getShopAppearCount():Int {
    if(getFloor() < 5) {
      // 序盤のフロアでは出現しない
      return 0;
    }
    return _shopAppearCount;
  }
  public static function getShopAppearCountRaw():Int {
    return _shopAppearCount;
  }
  public static function setShopAppearCount(v:Int):Void {
    _shopAppearCount = v;
  }
  public static function nextShopAppearCount():Void {
    _shopAppearCount += FlxRandom.intRanged(1, 2);
  }
  public static function resetShopAppearCount():Void {
    _shopAppearCount = 0;
  }
}
