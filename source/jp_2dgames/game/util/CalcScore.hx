package jp_2dgames.game.util;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Enemy;

/**
 * スコア計算モジュール
 **/
class CalcScore {

  // リザルト用に保存
  private static var _exp:Int = 0;       // 経験値のスコア
  private static var _money:Int = 0;     // 所持金
  private static var _inventory:Int = 0; // 所持アイテム

  // 保存しているスコアを取得
  // 経験値
  public static function getExp():Int {
    return _exp;
  }
  // 所持金
  public static function getMoeny():Int {
    return _money;
  }
  // 所持アイテム
  public static function getInventory():Int {
    return _inventory;
  }
  // トータルスコアを取得
  public static function getTotal():Int {
    return _exp + _money + _inventory;
  }

  /**
   * 更新
   **/
  public static function proc() {
    var score = 0;

    var player = Enemy.target;
    if(player == null) {
      return;
    }

    // 経験値
    _exp = player.params.exp * 3;
    score += _exp;

    // 所持金
    _money = Global.getMoney();
    score += _money;

    // 所持アイテム
    _inventory = Inventory.getScore();
    score += _inventory;

    // ゲームクリア判定
    if(Global.isGameClear()) {
      // クリアしていたらスコアを1.5倍
      score = Std.int(score * 1.5);
    }

    // スコアに反映
    Global.setScore(score);
  }

}
