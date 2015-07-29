package jp_2dgames.game;

/**
 * 経験値管理
 **/
class ExpMgr {

  private static var _val:Int = 0;

  /**
   * 経験値初期化
   **/
  public static function reset():Void {
    _val = 0;
  }

  /**
   * 経験値追加
   **/
  public static function add(val:Int):Void {
    _val += val;
  }

  /**
   * 経験値取得
   **/
  public static function get():Int {
    return _val;
  }

  public function new() {
  }
}
