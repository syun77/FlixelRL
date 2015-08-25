package jp_2dgames.game;

import jp_2dgames.game.unlock.UnlockMgr;
import jp_2dgames.game.save.GameData;
import jp_2dgames.game.util.CauseOfDeathMgr;
import flixel.FlxG;
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

  // ゲーム開始フロア数
  public static inline var FLOOR_FIRST:Int = 1;
  // 特殊マップ開始番号
  public static inline var MAP_ID_EXTRA_FIRST:Int = 500;
  // ゲーム開始時の所持金
  private static inline var MONEY_FIRST:Int = 300;
  // ショップ出現開始フロア数
  private static inline var SHOP_APPEAR_FIRST:Int = 3;
  // フラグの最大数
  public static inline var BIT_MAX:Int = 32;
  // フロアの最大数
  public static inline var FLOOR_MAX:Int = 30;

  /**
   * 初期化
   **/
  public static function init():Void {
    _bLoadGame = false;
    _score = 0;
    _playtime = 0;
    _floor = FLOOR_FIRST;
    _mapid = 0;
    _money = MONEY_FIRST;
    _moneyadd = 0;
    _items = new Array<ItemData>();
    _nCursorInventory = 0;
    _itemMaxInventory = Inventory.ITEM_MAX_FIRST;
    _bInitPlayer = true;
    _params = new Params();
    _shopAppearCount = 100;
    _nightmareLv = 1;
    _turnLimitNightmare = NightmareMgr.getTurnLimit();
    _nightmareAvoid = 0;
    _bEscapeFromNightmare = false;
    _nightmareDefeat = false;
    _bitsInit();
    _bGameClear = false;
    CauseOfDeathMgr.init();
  }

  // セーブデータをロードしてゲームを開始する
  private static var _bLoadGame:Bool = false;
  public static function SetLoadGame(b:Bool):Void {
    _bLoadGame = b;
  }
  public static function isLoadGame():Bool {
    return _bLoadGame;
  }

  // スコア
  private static var _score:Int = 0;
  public static function getScore():Int {
    return _score;
  }
  public static function setScore(v:Int):Void {
    _score = v;
  }
  public static function addScore(v:Int):Void {
    _score += v;
  }

  // プレイ時間
  private static var _playtime:Float = 0;
  public static function getPlayTime():Float {
    return _playtime;
  }
  public static function setPlayTime(sec:Float) {
    _playtime = sec;
  }
  public static function addPlayTime(add_sec:Float) {
    _playtime += add_sec;
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
  // 現在のマップが特殊フロアかどうか
  public static function isMapExtra():Bool {
    return _mapid >= MAP_ID_EXTRA_FIRST;
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
    var map = TextUtil.fillZero(_floor, 3);
    var path = 'assets/levels/${map}.tmx';
    if(Assets.exists(path, TEXT) == false) {
      _floor = 1;
    }

    // 到達最大フロア数を更新
    if(GameData.getPlayData().maxFloor < _floor) {
      GameData.getPlayData().maxFloor = _floor;
    }

    // 所持金増加演出終わり
    _moneyadd = 0;
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
    _moneyadd = v;

    // 所持金アンロックのチェック
    UnlockMgr.check("money", _money);

    // トータル金額に加算
    GameData.getPlayData().totalMoney += v;

    // 最大所持金チェック
    if(GameData.getPlayData().maxMoney < _money) {
      GameData.getPlayData().maxMoney = _money;
      GameData.save();
    }
    return _money;
  }
  public static function useMoney(v:Int):Int {
    _money -= v;
    if(_money < 0) {
      _money = 0;
    }
    _moneyadd = -v;
    return _money;
  }
  private static var _moneyadd:Int = 0;
  public static function getMoneyAdd():Int {
    return _moneyadd;
  }
  public static function resetMoneyAdd():Void {
    _moneyadd = 0;
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
  // ナイトメアから逃走したかどうか
  private static var _bEscapeFromNightmare:Bool = false;
  public static function isEscapeFromNightmare():Bool {
    return _bEscapeFromNightmare;
  }
  public static function setEscapeFromNightmare(b:Bool):Void {
    _bEscapeFromNightmare = b;
  }

  // ショップ出現カウント
  private static var _shopAppearCount:Int = 0;
  public static function getShopAppearCount():Int {
    if(getFloor() < SHOP_APPEAR_FIRST) {
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

  // ビットフラグ
  private static var _bits:Array<Bool> = null;
  private static function _bitsInit():Void {
    _bits = [for(i in 0...BIT_MAX) false];
  }
  public static function bitOn(idx:Int):Void {
    if(_bits == null) {
      return;
    }
    if(idx < 0 || BIT_MAX <= idx) {
      FlxG.log.warn('Invalid bit idx=${idx}');
      return;
    }
    _bits[idx] = true;
  }
  public static function bitOff(idx:Int):Void {
    if(_bits == null) {
      return;
    }
    if(idx < 0 || BIT_MAX <= idx) {
      FlxG.log.warn('Invalid bit idx=${idx}');
      return;
    }
    _bits[idx] = false;
  }
  public static function bitChk(idx:Int):Bool {
    if(_bits == null) {
      return false;
    }
    if(idx < 0 || BIT_MAX <= idx) {
      FlxG.log.warn('Invalid bit idx=${idx}');
      return false;
    }
    return _bits[idx];
  }

  // ゲームクリアフラグ
  private static var _bGameClear = false;
  public static function gameClear():Void {
    _bGameClear = true;
  }
  public static function isGameClear():Bool {
    return _bGameClear;
  }
}
