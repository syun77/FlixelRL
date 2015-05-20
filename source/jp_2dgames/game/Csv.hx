package jp_2dgames.game;
import jp_2dgames.lib.CsvLoader;

/**
 * CSV読み込みモジュール
 **/
class Csv {
  // 敵情報
  private var _enemy:CsvLoader = null;
  public var enemy(get_enemy, null):CsvLoader;

  private function get_enemy() {
    return _enemy;
  }
  // 消費アイテム
  private var _itemConsumable:CsvLoader = null;
  public var itemConsumable(get_itemConsumable, null):CsvLoader;

  private function get_itemConsumable() {
    return _itemConsumable;
  }
  // 装備アイテム
  private var _itemEquipment:CsvLoader = null;
  public var itemEquipment(get_itemEquipment, null):CsvLoader;

  private function get_itemEquipment() {
    return _itemEquipment;
  }
  // メッセージ
  private var _message:CsvLoader = null;
  public var message(get, null):CsvLoader;

  private function get_message() {
    return _message;
  }

  public function new() {
    _enemy = new CsvLoader("assets/levels/enemy.csv");
    _itemConsumable = new CsvLoader("assets/levels/item_consumable.csv");
    _itemEquipment = new CsvLoader("assets/levels/item_equipment.csv");
    _message = new CsvLoader("assets/data/message.csv");
  }

  // メッセージの取得
  public function getMessage(id:Int):String {
    return _message.searchItem("id", '${id}', "msg");
  }

}
