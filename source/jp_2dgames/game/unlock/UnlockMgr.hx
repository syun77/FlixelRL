package jp_2dgames.game.unlock;
import jp_2dgames.lib.CsvLoader;

/**
 * アンロック管理
 **/
class UnlockMgr {

  private static var _instance:UnlockMgr = null;
  public static function createInstance() {
    if(_instance == null) {
      _instance = new UnlockMgr();
    }
  }
  public static function destroyInstance() {
    _instance = null;
  }

  private var _csv:CsvLoader;

  // パラメータ取得
  public static function getParam(id:Int, name:String):String {
    return _instance._getParam(id, name);
  }
  private function _getParam(id:Int, name:String):String {
    return _csv.getString(id, name);
  }
  public static function getParamInt(id:Int, name:String):Int {
    return _instance._getParamInt(id, name);
  }
  private function _getParamInt(id:Int, name:String):Int {
    return _csv.getInt(id, name);
  }
  public static function maxSize():Int {
    return _instance._maxSize();
  }
  private function _maxSize():Int {
    return _csv.size();
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    _csv = new CsvLoader("assets/data/achievement.csv");
  }

}
