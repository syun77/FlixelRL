package jp_2dgames.game;

import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.DirUtil.Dir;
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
    _money = 0;
    _items = new Array<ItemData>();
    _bInitPlayer = true;
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
	 * 現在のフロアのマップデータのパスを取得する
	 **/
  public static function getFloorMap():String {
    var map = TextUtil.fillZero(_floor, 3);
    return 'assets/levels/${map}.tmx';
  }

  /**
	 * 次のフロアに進む
	 **/
  public static function nextFloor():Void {
    _floor++;
    // TODO: 最後まで進んだら最初に戻る
    if(_floor > 3) {
      _floor = 1;
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
    }
    else {
      // 外部のデータを使う
      _items = items;
    }
    Inventory.setItemList(items);
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
}
