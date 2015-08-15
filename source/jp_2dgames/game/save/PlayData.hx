package jp_2dgames.game.save;

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
  // 最大スコア
  public var maxScore:Int = 0;
  // フロア最大到達数
  public var maxFloor:Int = 1;
  // 最大レベル
  public var maxLv:Int = 1;
  // 最大所持金
  public var maxMoney:Int = 0;
  // 最大アイテム所持数
  public var maxItem:Int = 0;
  // アイテム獲得フラグ
  public var flgItemFind:Array<Int>;
  // 敵の撃破数
  public var cntEnemyKill:Int = 0;
  // 敵の撃破フラグ
  public var flgEnemyKill:Array<Int>;

  /**
   * コンストラクタ
   **/
  public function new() {
    flgEnemyKill = new Array<Int>();
    flgItemFind  = new Array<Int>();
  }

  /**
   * コピー
   **/
  public function copyFromDynamic(data:Dynamic) {
    playtime     = data.playtime;
    cntPlay      = data.cntPlay;
    cntGameclear = data.cntGameclear;
    maxScore     = data.maxScore;
    maxFloor     = data.maxFloor;
    maxLv        = data.maxLv;
    maxMoney     = data.maxMoney;
    maxItem      = data.maxItem;
    var itemidList:Array<Int> = data.flgItemFind;
    for(itemid in itemidList) {
      flgItemFind.push(itemid);
    }
    cntEnemyKill = data.cntEnemyKill;
    var enemyidList:Array<Int> = data.flgEnemyKill;
    for(enemyid in enemyidList) {
      flgEnemyKill.push(enemyid);
    }
  }
}
