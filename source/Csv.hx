package ;
import jp_2dgames.CsvLoader;

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

	public function new() {
		_enemy = new CsvLoader("assets/levels/enemy.csv");
		_itemConsumable = new CsvLoader("assets/levels/item_consumable.csv");
		_itemEquipment = new CsvLoader("assets/levels/item_equipment.csv");
	}
}
