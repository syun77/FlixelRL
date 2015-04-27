package ;

import ItemUtil.IType;

/**
 * アイテムデータ
 **/
class Item {
	// アイテムID
	public var id(default, null):Int;
	// アイテム種別
	public var type(default, null):IType;

	public function new() {
	}
}
