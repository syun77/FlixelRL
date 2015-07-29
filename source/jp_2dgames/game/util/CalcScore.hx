package jp_2dgames.game.util;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Enemy;

/**
 * スコア計算モジュール
 **/
class CalcScore {
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
    score += player.params.exp * 10;

    // 所持金
    score += Global.getMoney();

    // 所持アイテム
    score += Inventory.getScore();

    // スコアに反映
    Global.setScore(score);
  }
}
