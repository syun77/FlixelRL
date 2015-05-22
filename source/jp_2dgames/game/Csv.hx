package jp_2dgames.game;
import jp_2dgames.lib.CsvLoader;

/**
 * CSV読み込みモジュール
 **/
class Csv {
  // プレイヤー情報
  private var _player:CsvLoader = null;
  public var player(get, null):CsvLoader;
  private function get_player() {
    return _player;
  }
  // 敵情報
  private var _enemy:CsvLoader = null;
  public var enemy(get, null):CsvLoader;
  private function get_enemy() {
    return _enemy;
  }
  // 消費アイテム
  private var _itemConsumable:CsvLoader = null;
  public var itemConsumable(get, null):CsvLoader;

  private function get_itemConsumable() {
    return _itemConsumable;
  }
  // 装備アイテム
  private var _itemEquipment:CsvLoader = null;
  public var itemEquipment(get, null):CsvLoader;

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
    _player = new CsvLoader("assets/levels/player.csv");
    _enemy = new CsvLoader("assets/levels/enemy.csv");
    _itemConsumable = new CsvLoader("assets/levels/item_consumable.csv");
    _itemEquipment = new CsvLoader("assets/levels/item_equipment.csv");
    _message = new CsvLoader("assets/data/message.csv");
  }

}
