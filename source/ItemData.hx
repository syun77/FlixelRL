package ;

import ItemUtil.IType;

/**
 * アイテムデータ
 **/
class ItemData {
	public var id(default, default):Int;       // アイテムID
	public var type(default, default):IType;   // アイテム種別
	public var isEquip(default, default):Bool; // 装備しているかどうか
	public function new(itemid:Int) {
		id = itemid;
		type = ItemUtil.getType(id);
		isEquip = false;
	}
}

