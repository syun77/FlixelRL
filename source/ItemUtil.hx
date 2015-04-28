package ;

import flixel.util.FlxRandom;
import jp_2dgames.CsvLoader;

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
	Food;    // 食べ物
}

/**
 * アイテムユーティリティ
 **/
class ItemUtil {
	private static inline var ID_OFFSET:Int = 1000;

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

	public static function toString(type:IType):String {
		return '${type}';
	}
	public static function fromString(str:String):IType {
		switch(str) {
			case '${IType.Weapon}': return IType.Weapon;
			case '${IType.Armor}': return IType.Armor;
			case '${IType.Scroll}': return IType.Scroll;
			case '${IType.Wand}': return IType.Wand;
			case '${IType.Portion}': return IType.Portion;
			case '${IType.Ring}': return IType.Ring;
			case '${IType.Food}': return IType.Food;
			default: return IType.None;
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
			case IType.Food:
				return FlxRandom.intRanged(1, 2);
			case IType.Portion:
				return FlxRandom.intRanged(3, 4);
			default:
				return 0;
		}
	}
}
