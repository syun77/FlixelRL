package jp_2dgames.game.playlog;

import flixel.util.FlxSave;
/**
 * プレイログデータ管理
 **/
class PlayLog {
  // セーブデータ名
  private static inline var DATA_NAME = "PLAYLOG";

  // ログデータ
  private static var _logs:Array<PlayLogData> = null;

  /**
   * ログデータを取得する
   **/
  public static function getLogs():Array<PlayLogData> {
    return _logs;
  }
  /**
   * ログの数を取得する
   **/
  public static function count():Int {
    if(exists() == false) {
      return 0;
    }
    if(_logs == null) {
      return 0;
    }

    return _logs.length;
  }

  /**
   * ログデータを追加
   **/
  public static function add(log:PlayLogData):Void {
    _logs.push(log);
  }
  /**
   * セーブ
   **/
  public static function save():Void {
    var save = new FlxSave();
    save.bind(DATA_NAME);
    save.data.logs = _logs;

    // 書き込み
    save.flush();
  }
  /**
   * ロード
   **/
  public static function load():Void {
    _logs = new Array<PlayLogData>();

    if(exists()) {
      // セーブデータがあればそこから読み込み
      var save = new FlxSave();
      save.bind(DATA_NAME);
      var logs:Array<Dynamic> = save.data.logs;
      for(data in logs) {
        var log = new PlayLogData();
        log.copyFromDynamic(data);
        add(log);
      }
    }
  }
  /**
   * セーブデータが存在するかどうか
   **/
  public static function exists():Bool {
    var save = new FlxSave();
    save.bind(DATA_NAME);
    if(save.data == null) {
      return false;
    }
    if(save.data.logs == null) {
      return false;
    }
    return true;
  }
  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var save = new FlxSave();
    save.bind(DATA_NAME);
    save.erase();
  }
}
