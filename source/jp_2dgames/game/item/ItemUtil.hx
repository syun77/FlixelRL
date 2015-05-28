package jp_2dgames.game.item;

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

  public static function getName(id:Int):String {
    var csv = getCsv(id);
    return csv.searchItem("id", '${id}', "name");
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
        return FlxRandom.intRanged(0, 1);
      case IType.Money:
        return 100;
      case IType.Food:
        return FlxRandom.intRanged(1, 2);
      case IType.Portion:
        return FlxRandom.intRanged(3, 4);
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

  /**
   * 消費アイテムを使用する
   **/
  public static function use(player:Player, item:ItemData):Void {
    switch(item.type) {
      case IType.Portion:
        // 薬
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          player.addHp(val);
        }
        else {
          val = ItemUtil.getParam(item.id, "hp2");
          player.addHp2(val);
        }
      case IType.Food:
        // 食糧
        var val = ItemUtil.getParam(item.id, "food");
        player.addFood(val);
      default:
        // ここにくることはない
        trace('Error: Invalid item ${item.id}');
    }
  }
}
