package ;

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

	public static function getCsv(type:IType):CsvLoader {
		if(isConsumable(type)) {
			return csvConsumable;
		}
		else {
			return csvEquipment;
		}
	}

	public static function getName(type:IType, id:Int):String {
		var csv = getCsv(type);
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
	public static function isEquip(type:IType):Bool {
		switch(type) {
			case IType.Weapon: return true;
			case IType.Armor: return true;
			case IType.Ring: return true;
			default: return false;
		}
	}

	// 消費アイテムかどうか
	public static function isConsumable(type:IType):Bool {
		// 装備アイテムでなければ消費アイテム
		return !isEquip(type);
	}

	// アイテムの通し番号を取得する
	public static function toIdx(type:IType, id:Int):Int {
		if(isConsumable(type)) {
			// 消費アイテムはそのままの番号
			return id;
		}
		else {
			// 装備アイテムはオフセットして返す
			return ID_OFFSET + id;
		}
	}

}
