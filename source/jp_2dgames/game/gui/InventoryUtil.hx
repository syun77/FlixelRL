package jp_2dgames.game.gui;

import jp_2dgames.game.NightmareMgr.NightmareSkill;
import jp_2dgames.game.item.ItemUtil;

/**
 * インベントリのユーティリティ
 **/
class InventoryUtil {
  public static function getWeaponExtra():String {
    var id = Inventory.getWeapon();
    return ItemUtil.getExtra(id);
  }
  public static function getWeaponExtVal():Int {
    var id = Inventory.getWeapon();
    return ItemUtil.getExtVal(id);
  }
  public static function getArmorExtra():String {
    var id = Inventory.getArmor();
    return ItemUtil.getExtra(id);
  }
  public static function getArmorExtVal():Int {
    var id = Inventory.getArmor();
    return ItemUtil.getExtVal(id);
  }
  public static function getRingExtra():String {
    if(NightmareMgr.getSkill() == NightmareSkill.Ring) {
      // 指輪効果無効
      return "";
    }

    var id = Inventory.getRing();
    return ItemUtil.getExtra(id);
  }
  public static function getRingExtVal():Int {
    var id = Inventory.getRing();
    return ItemUtil.getExtVal(id);
  }
}
