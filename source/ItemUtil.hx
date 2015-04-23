package ;

/**
 * アイテム種別
 **/
enum IType {
	None;    // なし
	Sword;   // 剣
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
	public static function toString(type:IType):String {
		return '${type}';
	}
	public static function fromString(str:String):IType {
		switch(str) {
			case '${IType.Sword}': return IType.Sword;
			case '${IType.Armor}': return IType.Armor;
			case '${IType.Scroll}': return IType.Scroll;
			case '${IType.Wand}': return IType.Wand;
			case '${IType.Portion}': return IType.Portion;
			case '${IType.Ring}': return IType.Ring;
			case '${IType.Food}': return IType.Food;
			default: return IType.None;
		}
	}
}
