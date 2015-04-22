package ;
import jp_2dgames.CsvLoader;

/**
 * CSV読み込みモジュール
 **/
class Csv {
	private var _enemy:CsvLoader = null;
	public var enemy(get_enemy, null):CsvLoader;
	private function get_enemy() {
		return _enemy;
	}
	public function new() {
		_enemy = new CsvLoader("assets/levels/enemy.csv");
	}
}
