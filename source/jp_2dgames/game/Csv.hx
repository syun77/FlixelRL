package jp_2dgames.game;
import jp_2dgames.lib.CsvLoader;

/**
 * CSV読み込みモジュール
 **/
class Csv {
  // プレイヤー情報
  private var _player:CsvLoader = null;
  public var player(get, never):CsvLoader;
  private function get_player() {
    return _player;
  }
  // 敵情報
  private var _enemy:CsvLoader = null;
  public var enemy(get, never):CsvLoader;
  private function get_enemy() {
    return _enemy;
  }
  // 敵出現
  private var _enemy_appear:CsvLoader = null;
  public var enemy_appear(get, never):CsvLoader;
  private function get_enemy_appear() {
    return _enemy_appear;
  }
  // ナイトメア出現
  private var _enemy_nightmare:CsvLoader = null;
  public var enemy_nightmare(get, never):CsvLoader;
  private function get_enemy_nightmare() {
    return _enemy_nightmare;
  }

  // アイテム出現テーブル
  private var _item_appear:CsvLoader = null;
  public var item_appear(get, never):CsvLoader;
  private function get_item_appear() {
    return _item_appear;
  }
  // メッセージ
  private var _message:CsvLoader = null;
  public var message(get, never):CsvLoader;

  private function get_message() {
    return _message;
  }
  // UIテキスト
  private var _uitext:CsvLoader = null;
  public var uitext(get, never):CsvLoader;
  private function get_uitext() {
    return _uitext;
  }
  // ヒント
  private var _hint:CsvLoader = null;
  public var hint(get, never):CsvLoader;
  private function get_hint() {
    return _hint;
  }

  public function new() {
    _player = new CsvLoader("assets/levels/player.csv");
    _enemy = new CsvLoader("assets/levels/enemy.csv");
    _enemy_appear = new CsvLoader("assets/levels/enemy_appear.csv");
    _enemy_nightmare = new CsvLoader("assets/levels/enemy_nightmare.csv");
    _item_appear = new CsvLoader("assets/levels/item_appear.csv");
    _message = new CsvLoader("assets/data/message.csv");
    _uitext = new CsvLoader("assets/data/uitext.csv");
    _hint = new CsvLoader("assets/data/hint.csv");
  }

  /**
   * 敵出現テーブルを参照する番号を取得する
   **/
  public function getEnemyAppearId(floor:Int):Int {
    // 参照するデータ番号を調べる
    return _enemy_appear.foreachSearchID(function(data) {
      var start = Std.parseInt(data["start"]);
      var end = Std.parseInt(data["end"]);
      if(start <= floor && floor <= end) {
        return true;
      }
      return false;
    });
  }
}
