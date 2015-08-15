package jp_2dgames.game.save;

/**
 * 実績用データ
 **/
class Achievement {
  // トータルプレイ時間(秒)
  public var playtime:Float;
  // プレイ回数
  public var cntPlay:Int;
  // ゲームクリア回数
  public var cntGameclear:Int;
  // 最大スコア
  public var maxScore:Int;
  // フロア最大到達数
  public var maxFloor:Int;
  // 最大レベル
  public var maxLv:Int;
  // 最大所持金
  public var maxMoney:Int;
  // 最大アイテム所持数
  public var maxItem:Int;
  // 敵の撃破数
  public var cntEnemyKill:Int;
  // 敵の撃破フラグ
  public var flgEnemyKill:Array<Bool>;


  public function new() {
  }
}
