package jp_2dgames.game.util;

import jp_2dgames.game.actor.Enemy;

/**
 * 死因種別
 **/
enum DeathType {
  None;    // なし
  EnemyAtk;// 敵の攻撃
  Hunger;  // 餓死
  Spike;   // スパイク
  Reflect; // ダメージ反射
  Poison;  // 毒
}

/**
 * 死亡理由管理
 **/
class CauseOfDeathMgr {

  private static var _type:DeathType;
  private static var _value:Int;

  public static function init():Void {
    _type  = DeathType.None;
    _value = 0;
  }

  public static function set(type:DeathType, value:Int) {
    _type = type;
    _value = value;
  }

  public static function getMessage():String {
    if(Global.isGameClear()) {
      return "ゲームクリア";
    }

    switch(_type) {
      case DeathType.None:
        return "";

      case DeathType.EnemyAtk:
        return Enemy.getNameFromID(_value) + "に倒された";

      case DeathType.Hunger:
        return "空腹で倒れた";

      case DeathType.Spike:
        return "ダメージ床で力尽きた";

      case DeathType.Reflect:
        return Enemy.getNameFromID(_value) + "のダメージ反射で倒された";

      case DeathType.Poison:
        return "毒のダメージで倒れた";

      default:
        return "";
    }
  }

}
