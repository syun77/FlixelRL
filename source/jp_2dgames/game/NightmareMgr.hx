package jp_2dgames.game;

/**
 * ナイトメア管理
 **/
class NightmareMgr {
  // ゲーム開始時の残りターン数
  public static inline var TURN_LIMIT_FIRST:Int = 120;

  public static var instance:NightmareMgr = null;

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  /**
   * 次のターンに進む
   **/
  public function nextTurn():Void {
    var v = Global.getTurnLimitNightmare();
    // ターン数を減らす
    v -= 1;
    if(v < 0) {
      v = 0;
    }
    Global.setTurnLimitNightmare(v);
  }
}
