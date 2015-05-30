package jp_2dgames.game;

import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxRandom;

/**
 * 各種計算式
 **/
class Calc {

  // 最大ダメージ
  private static inline var MAX_DAMAGE:Int = 9999;

  /**
	 * ダメージ計算
	 * @param act1 攻撃する人
	 * @param act2 攻撃される人
	 * @param item1 act1の装備アイテム
	 * @param item2 act2の装備アイテム
	 **/
  public static function damage(act1:Actor, act2:Actor, item1:Int, item2:Int):Int {
    // 力
    var str = act1.params.str;
    // 耐久力
    var vit = act2.params.vit;
    // 攻撃力
    var atk = 0;
    if(item1 > ItemUtil.NONE) {
      // 攻撃力を取得
      atk = ItemUtil.getParam(item1, "atk");
    }
    // 防御力
    var def = 0;
    if(item2 > ItemUtil.NONE) {
      // 防御力を取得
      def = ItemUtil.getParam(item2, "def");
    }

    // 威力
    var power = str + atk + 5;

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.15, atk - def);

//    trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

    // ダメージ量を計算
    var val = (power * str_rate * power_rate);
    if(val <= 0) {
      // 0ダメージはランダムで1〜3ダメージ
      val = FlxRandom.intRanged(1, 3);
    }
    else {
      // ランダムで+5%変動
      var d = val * FlxRandom.floatRanged(0, 0.05);
      if(Math.abs(d) < 1) {
        // 1以下の場合は+1〜3する
        val += FlxRandom.intRanged(1, 3);
      }
      else {
        val += d;
        if(val > MAX_DAMAGE) {
          // 最大ダメージ量を超えないようにする
          val = MAX_DAMAGE;
        }
      }
    }

    return Std.int(val);
  }

  /**
   * 攻撃が当たるかどうかをチェック
   **/
  public static function checkHitAttack():Bool {
    // 92%の確率で当たる
    return FlxRandom.chanceRoll(92);
  }

  /**
   * 敵の攻撃が当たるかどうかをチェック
   **/
  public static function checkHitAttackForEnemy():Bool {
    // 87%の確率で当たる
    return FlxRandom.chanceRoll(87);
  }

  /**
   * アイテム投げが当たるかどうかチェック
   **/
  public static function checkHitThrow():Bool {
    // 87%の確率で当たる
    return FlxRandom.chanceRoll(87);
  }
}
