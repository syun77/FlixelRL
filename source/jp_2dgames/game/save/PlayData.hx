package jp_2dgames.game.save;

import jp_2dgames.game.gui.Inventory;

/**
 * ゲームプレイデータ
 **/
class PlayData {
  // トータルプレイ時間(秒)
  public var playtime:Float = 0;
  // プレイ回数
  public var cntPlay:Int = 0;
  // ゲームクリア回数
  public var cntGameclear:Int = 0;
  // 敵の撃破数
  public var cntEnemyKill:Int = 0;
  // ナイトメア撃破数
  public var cntNightmareKill:Int = 0;
  // 拾ったお金の総額
  public var totalMoney:Int = 0;
  // アイテム獲得数
  public var totalItem:Int = 0;
  // フロア最大到達数
  public var maxFloor:Int = 1;
  // 最大レベル
  public var maxLv:Int = 1;
  // 最大所持金
  public var maxMoney:Int = 0;
  // 最大アイテム所持限度数
  public var maxItem:Int = Inventory.ITEM_MAX_FIRST;
  // アイテム獲得フラグ
  public var flgItemFind:Array<Int>;
  // 敵の撃破フラグ
  public var flgEnemyKill:Array<Int>;
  // 実績解除フラグ
  public var flgUnlock:Array<Int>;

  /**
   * コンストラクタ
   **/
  public function new() {
    flgEnemyKill = new Array<Int>();
    flgItemFind  = new Array<Int>();
    flgUnlock    = new Array<Int>();
  }

  /**
   * コピー
   **/
  public function copyFromDynamic(data:Dynamic) {
    playtime     = data.playtime;
    cntPlay      = data.cntPlay;
    cntGameclear = data.cntGameclear;
    cntEnemyKill = data.cntEnemyKill;
    totalMoney   = data.totalMoney;
    totalItem    = data.totalItem;
    cntNightmareKill = data.cntNightmareKill;
    maxFloor     = data.maxFloor;
    maxLv        = data.maxLv;
    maxMoney     = data.maxMoney;
    maxItem      = data.maxItem;
    var itemidList:Array<Int> = data.flgItemFind;
    for(itemid in itemidList) {
      flgItemFind.push(itemid);
    }
    var enemyidList:Array<Int> = data.flgEnemyKill;
    for(enemyid in enemyidList) {
      flgEnemyKill.push(enemyid);
    }
    var unlockList:Array<Int> = data.flgUnlock;
    for(unlock in unlockList) {
//      flgUnlock.push(unlock);
    }
  }
}
