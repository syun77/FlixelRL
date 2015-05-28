package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil.IType;

/**
 * アイテム拡張パラメータ
 **/
class ItemExtraParam {
  public var value:Int = 0;

  public function new() {
  }

  /**
   * 拡張パラメータをコピー
   **/
  public static function copy(dst:ItemExtraParam, src:ItemExtraParam):Void {
    if(src == null) {
      dst.value = 0;
      return;
    }
    dst.value = src.value;
  }
}

/**
 * アイテムデータ
 **/
class ItemData {
  public var id(default, default):Int; // アイテムID
  public var type(default, default):IType; // アイテム種別
  public var isEquip(default, default):Bool; // 装備しているかどうか
  public var param:ItemExtraParam; // 拡張パラメータ


//  public function new(itemid:Int, param:ItemExtraParam=null) {
  public function new(itemid:Int, param:ItemExtraParam) {
    id = itemid;
    type = ItemUtil.getType(id);
    isEquip = false;
    this.param = new ItemExtraParam();
    ItemExtraParam.copy(this.param, param);
  }
}

