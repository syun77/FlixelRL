package jp_2dgames.game.util;

import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.actor.Enemy;

/**
 * 死因種別
 **/
enum DeathType {
  None;       // なし
  EnemyAtk;   // 敵の攻撃
  Hunger;     // 餓死
  Spike;      // スパイク
  ReflectAtk; // ダメージ反射
  Poison;     // 毒
}

/**
 * 死亡理由管理
 **/
class CauseOfDeathMgr {

  // メッセージ定数
  private static inline var MSG_GAMECLEAR:Int = 1;
  private static inline var MSG_ENEMYATK:Int  = 2;
  private static inline var MSG_HUMGER:Int    = 3;
  private static inline var MSG_PIT:Int       = 4;
  private static inline var MSG_REFLECT:Int   = 5;
  private static inline var MSG_POISON:Int    = 6;

  private static var _type:DeathType = DeathType.None;
  private static var _value:Int = 0;
  private static var _csv:CsvLoader;

  public static function create():Void {
    _csv = new CsvLoader("assets/data/deathtype.csv");
  }

  public static function init():Void {
    _type  = DeathType.None;
    _value = 0;
  }

  public static function set(type:DeathType, value:Int) {
    _type = type;
    _value = value;
  }

  private static function _getMessage(msgid:Int, param:String=""):String {
    var msg = _csv.getString(msgid, "msg");
    return StringTools.replace(msg, "<val1>", param);
  }

  /**
   * 死亡原因に対応するIDを取得する
   **/
  public static function toIdx():Int {
    if(Global.isGameClear()) {
      return MSG_GAMECLEAR;
    }

    switch(_type) {
      case DeathType.EnemyAtk:
        return MSG_ENEMYATK;

      case DeathType.Hunger:
        return MSG_HUMGER;

      case DeathType.Spike:
        return MSG_PIT;

      case DeathType.ReflectAtk:
        return MSG_REFLECT;

      case DeathType.Poison:
        return MSG_POISON;

      default:
        return 0;
    }
  }

  public static function getMessage():String {
    if(Global.isGameClear()) {
      return _getMessage(MSG_GAMECLEAR);
    }

    switch(_type) {
      case DeathType.None:
        return "";

      case DeathType.EnemyAtk:
        var name = Enemy.getNameFromID(_value);
        return _getMessage(MSG_ENEMYATK, name);

      case DeathType.Hunger:
        return _getMessage(MSG_HUMGER);

      case DeathType.Spike:
        return _getMessage(MSG_PIT);

      case DeathType.ReflectAtk:
        var name = Enemy.getNameFromID(_value);
        return _getMessage(MSG_REFLECT, name);

      case DeathType.Poison:
        return _getMessage(MSG_POISON);
    }
  }

}
