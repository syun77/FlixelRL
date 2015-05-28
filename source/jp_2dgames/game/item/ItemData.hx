package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil.IType;

/**
 * アイテムデータ
 **/
class ItemData {
  public var id(default, default):Int; // アイテムID
  public var type(default, default):IType; // アイテム種別
  public var isEquip(default, default):Bool; // 装備しているかどうか
  public var value(default, default):Int; // パラメータ

  public function new(itemid:Int, v:Int=0) {
    id = itemid;
    type = ItemUtil.getType(id);
    isEquip = false;
    value = v;
  }
}

