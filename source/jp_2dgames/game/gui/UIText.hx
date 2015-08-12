package jp_2dgames.game.gui;
import jp_2dgames.lib.CsvLoader;

/**
 * メニュー用テキスト管理
 **/
class UIText {

  // メニュー
  public static inline var MENU_NOUSE:Int = -1; // メニュー: 使えない
  public static inline var MENU_USE:Int = 1; // メニュー: 使う
  public static inline var MENU_EQUIP:Int = 2; // メニュー: 装備
  public static inline var MENU_UNEQUIP:Int = 3; // メニュー: 外す
  public static inline var MENU_THROW:Int = 4; // メニュー: 投げる
  public static inline var MENU_PUT:Int = 5; // メニュー: 置く
  public static inline var MENU_CHANGE:Int = 6; // メニュー: 交換
  public static inline var MENU_PICKUP:Int = 7; // メニュー: 拾う
  public static inline var MENU_NEXTFLOOR_MSG:Int = 8; // メニュー: 歓談がある
  public static inline var MENU_NEXTFLOOR:Int = 9; // メニュー: 下りる
  public static inline var MENU_STAY:Int = 10; // メニュー: そのまま
  public static inline var MENU_SHOP_MSG:Int = 11; // メニュー: お店がある
  public static inline var MENU_SHOP_BUY:Int = 12; // メニュー: 買う
  public static inline var MENU_SHOP_SELL:Int = 13; // メニュー: 売る
  public static inline var MENU_SHOP_NOTHING:Int = 14; // メニュー: 何もしない

  // ページ
  public static inline var PAGE_FEET:Int = 17; // 足下
  public static inline var PAGE_NOITEM:Int = 18; // 何も持っていない

  // ヘルプ
  public static inline var HELP_KEYINPUT:Int = 25; // ヘルプ: 通常
  public static inline var HELP_INVENCTORY:Int = 26; // ヘルプ: インベントリ
  public static inline var HELP_DIALOG:Int = 27; // ヘルプ: ダイアログ
  public static inline var HELP_INVENCTORYCOMMAND:Int = 28; // ヘルプ: インベントリ・コマンド
  public static inline var HELP_SHOP_SELL:Int = 29; // ヘルプ: ショップ（売却）
  public static inline var HELP_SHOP_BUY:Int = 30; // ヘルプ: ショップ（購入）

  // インスタンス
  public static var instance:UIText = null;

  // テキストCSV
  private var _csv:CsvLoader;

  /**
   * コンストラクタ
   **/
  public function new(csv:CsvLoader) {
    _csv = csv;
  }

  /**
   * メッセージを取得する
   **/
  public static function getText(msgId:Int):String {
    return instance._csv.searchItem("id", '${msgId}', "msg");
  }

}
