package jp_2dgames.game.util;

import flixel.util.FlxColor;

/**
 * 色関連の情報
 **/
class MyColor {
  // ■アイテムリスト
  // 選択可能
  public static inline var LISTITEM_ENABLE:Int = 0x006666;
  // 選択不可
  public static inline var LISTITEM_DISABLE:Int = 0x003333;
  // テキストの色
  public static inline var LISTITEM_TEXT:Int = 0x99FFCC;
  public static inline var CURSOR:Int = FlxColor.YELLOW;

  public static inline var COMMAND_FRAME:Int   = 0x00CCCC;
  public static inline var COMMAND_CURSOR:Int  = 0x33CCCC;
  public static inline var COMMAND_DISABLE:Int = 0x999999;
  public static inline var COMMAND_TEXT_SELECTED:Int = 0x000066;
  public static inline var COMMAND_TEXT_UNSELECTED:Int = 0x99FFCC;

  public static inline var DETAIL_FRAME:Int = 0x000033;
  public static inline var MESSAGE_WINDOW:Int = 0x000033;

  public static inline function strToColor(str:String):Int {
    switch(str) {
      case "white": return FlxColor.WHITE;
      case "red": return FlxColor.PINK;
      case "green": return FlxColor.LIME;
      case "blue": return FlxColor.AQUAMARINE;
      case "yellow": return FlxColor.YELLOW;
      case "orange": return FlxColor.WHEAT;
      default:
        return FlxColor.BLACK;
    }
  }
}
