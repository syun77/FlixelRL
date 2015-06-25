package jp_2dgames.game.item;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.util.FlxRandom;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.Player;
import flixel.util.FlxRandom;
import jp_2dgames.lib.CsvLoader;

/**
 * アイテム種別
 **/
enum IType {
  None;    // なし
  Weapon;  // 武器
  Armor;   // よろい
  Scroll;  // 巻物
  Wand;    // 杖
  Portion; // ポーション
  Ring;    // 指輪
  Money;   // お金
  Food;    // 食べ物
}

/**
 * アイテムユーティリティ
 **/
class ItemUtil {
  // 無効なアイテム番号
  public static inline var NONE = -1;
  static inline var ID_OFFSET:Int = 1000;

  public static var csvConsumable:CsvLoader = null;
  public static var csvEquipment:CsvLoader = null;

  public static function getCsv(id:Int):CsvLoader {
    if(isConsumable(id)) {
      return csvConsumable;
    }
    else {
      return csvEquipment;
    }
  }

  /**
   * アイテム名を取得する
   **/
  public static function getName(item:ItemData):String {
    var csv = getCsv(item.id);
    var name = csv.searchItem("id", '${item.id}', "name");
    switch(ItemUtil.getType(item.id)) {
      case IType.Weapon, IType.Armor:
        if(item.param.value != 0) {
          // ±がある
          var val = '${item.param.value}';
          if(item.param.value > 0) {
            val = '+${val}';
          }
          name = '${name}${val}[${item.param.condition}]';
        }
        else {
          name = '${name}[${item.param.condition}]';
        }
      default:
    }
    return name;
  }

  /**
   * アイテムの詳細説明文を取得する
   **/
  public static function getDetail(item:ItemData):String {
    var csv = getCsv(item.id);
    var detail = csv.searchItem("id", '${item.id}', "detail");
    return detail;
  }

  /**
	 * アイテムIDからアイテム種別を求める
	 **/
  public static function getType(id:Int):IType {
    var csv = getCsv(id);
    var str = csv.searchItem("id", '${id}', "type", false);
    if(str == "") {
      // 無効なアイテム
      return IType.None;
    }
    return fromString(str);
  }

  /**
	 * 指定のパラメータ名に対応するパラメータを取得する
	 **/
  public static function getParam(id:Int, key:String):Int {
    var csv = getCsv(id);
    return csv.searchItemInt("id", '${id}', key, false);
  }
  public static function getParamString(id:Int, key:String):String {
    var csv = getCsv(id);
    return csv.searchItem("id", '${id}', key);
  }

  public static function toString(type:IType):String {
    return '${type}';
  }

  public static function fromString(str:String):IType {
    // switchの条件に'${IType.###}'は使えない
    //		switch(str) {
    //			case '${IType.Weapon}': return IType.Weapon;
    //			case '${IType.Armor}': return IType.Armor;
    //			case '${IType.Scroll}': return IType.Scroll;
    //			case '${IType.Wand}': return IType.Wand;
    //			case '${IType.Portion}': return IType.Portion;
    //			case '${IType.Ring}': return IType.Ring;
    //			case '${IType.Food}': return IType.Food;
    //			default: throw "Error"; return IType.None;
    //		}
    if(str == '${IType.Weapon}') {
      return IType.Weapon;
    }
    else if(str == '${IType.Armor}') {
      return IType.Armor;
    }
    else if(str == '${IType.Scroll}') {
      return IType.Scroll;
    }
    else if(str == '${IType.Wand}') {
      return IType.Wand;
    }
    else if(str == '${IType.Portion}') {
      return IType.Portion;
    }
    else if(str == '${IType.Ring}') {
      return IType.Ring;
    }
    else if(str == '${IType.Money}') {
      return IType.Money;
    }
    else if(str == '${IType.Food}') {
      return IType.Food;
    }
    else {
      return IType.None;
    }
  }

  // 装備アイテムかどうか

  public static function isEquip(id:Int):Bool {
    if(id < ID_OFFSET) {
      return false;
    }
    else {
      return true;
    }
  }

  // 消費アイテムかどうか
  public static function isConsumable(id:Int):Bool {
    // 装備アイテムでなければ消費アイテム
    return !isEquip(id);
  }

  // ランダムでアイテムを取得する
  public static function random(type:IType):Int {
    switch(type) {
      case IType.Weapon:
        return FlxRandom.intRanged(1001, 1007);
      case IType.Armor:
        return FlxRandom.intRanged(1021, 1027);
      case IType.Ring:
        return FlxRandom.intRanged(1041, 1042);
      case IType.Money:
        return FlxRandom.intRanged(100, 1000);
      case IType.Food:
        return FlxRandom.intRanged(1, 2);
      case IType.Portion:
        return FlxRandom.intRanged(3, 4);
      case IType.Scroll:
        return FlxRandom.intRanged(33, 34);
      case IType.Wand:
        return FlxRandom.intRanged(49, 50);
      default:
        trace('Warning: invalid type ${type}');
        return 0;
    }
  }

  // ランダムでアイテム種別を取得する
  public static function randomType():IType {
    var tbl = [
      IType.Weapon,
      IType.Armor,
//      IType.Scroll,
//      IType.Wand,
      IType.Portion,
//      IType.Ring,
//      IType.Money,
      IType.Food,
    ];
    return tbl[FlxRandom.intRanged(0, tbl.length-1)];
  }

  // デバッグ用のアイテム種別を取得する
  public static function getDebugItemType():IType {
    if(FlxG.keys.pressed.U) {
      return IType.Weapon;
    }
    if(FlxG.keys.pressed.I) {
      return IType.Armor;
    }
    if(FlxG.keys.pressed.O) {
      return IType.Ring;
    }
    if(FlxG.keys.pressed.J) {
      return IType.Food;
    }
    if(FlxG.keys.pressed.K) {
      return IType.Portion;
    }
    if(FlxG.keys.pressed.L) {
      return IType.Money;
    }
    if(FlxG.keys.pressed.M) {
      return IType.Scroll;
    }
    if(FlxG.keys.pressed.COMMA) {
      return IType.Wand;
    }

    // 該当するキーを押していない
    return IType.None;
  }

  /**
   * 消費アイテムを使用する
   **/
  public static function use(actor:Actor, item:ItemData, bMsg=true):Void {
    // 拡張パラメータ
    var extra = ItemUtil.getParamString(item.id, "extra");
    var extval = ItemUtil.getParam(item.id, "extval");

    switch(item.type) {
      case IType.Portion:
        // 薬
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          actor.addHp(val);
          Message.push2(Msg.RECOVER_HP, [actor.name, val]);
        }

        if(extra != "") {
          // 特殊効果あり
          useExtra(actor, extra, extval);
        }

        // 満腹度も少し回復
        var val2 = ItemUtil.getParam(item.id, "food");
        actor.addFood(val2);
        FlxG.sound.play("recover");

      case IType.Food:
        // 食糧
        var val = ItemUtil.getParam(item.id, "food");
        actor.addFood(val);
        if(actor.isFoodMax()) {
          // 満腹になった
          Message.push2(Msg.RECOVER_FOOD_MAX);
        }
        else {
          Message.push2(Msg.RECOVER_FOOD);
        }
        switch(extra) {
          case "poison":
          // 毒状態になる
          actor.changeBadStatus(BadStatus.Poison);
          Message.push2(Msg.BAD_POISON, [actor.name]);
        }
        FlxG.sound.play("eat");

      case IType.Scroll:
        // 巻物
        // 何もしない

      default:
        // ここにくることはない
        trace('Error: Invalid item ${item.id}');
    }
  }

  /**
   * 特殊アイテムを使った
   **/
  public static function useExtra(actor:Actor, extra:String, extval:Int):Void {
    switch(extra) {
      case "hpmax":
        // 最大HP上昇
        actor.addHpMax(extval);
        Message.push2(Msg.GROW_HPMAX, [actor.name, extval]);
      case "food":
        // 最大満腹度上昇
        actor.addFoodMax(extval);
        Message.push2(Msg.GROW_FOOD, [extval]);
      case "str":
        // 力上昇
        actor.addStr(extval);
        Message.push2(Msg.GROW_STR, [extval]);
      case "poison":
        // 毒状態になる
        actor.changeBadStatus(BadStatus.Poison);
        Message.push2(Msg.BAD_POISON, [actor.name]);
      case "sleep":
        // 眠り状態になる
        actor.changeBadStatus(BadStatus.Sleep);
        Message.push2(Msg.BAD_SLEEP, [actor.name]);
      case "paralysis":
        // 麻痺状態になる
        actor.changeBadStatus(BadStatus.Paralysis);
        Message.push2(Msg.BAD_PARALYSIS, [actor.name]);
      case "confusion":
        // 混乱状態になる
        actor.changeBadStatus(BadStatus.Confusion);
        Message.push2(Msg.BAD_CONFUSION, [actor.name]);
      case "anger":
        // 怒り状態になる
        actor.changeBadStatus(BadStatus.Anger);
        Message.push2(Msg.BAD_AnGER, [actor.name]);
      case "powerful":
        // 元気状態になる
        actor.changeBadStatus(BadStatus.Powerful);
        Message.push2(Msg.BAD_POWERFUL, [actor.name]);
    }
  }

  /**
   * 巻物を使った
   **/
  public static function useScroll(actor:Actor, item:ItemData):Void {

  }
}
