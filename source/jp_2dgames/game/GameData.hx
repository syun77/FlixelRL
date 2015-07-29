package jp_2dgames.game;
import jp_2dgames.game.util.CauseOfDeathMgr;
import flash.external.ExternalInterface;
import jp_2dgames.game.util.NameGenerator;
import flixel.util.FlxSave;

/**
 * グローバルゲームデータ
 **/
class GameData {

  public static function init():Void {
    if(exists()) {
      // すでにデータがあるので何もしない
      return;
    }

    // ■新規作成
    // 名前を自動設定
    var generator = new NameGenerator();
    _name = generator.get();

    // いったんセーブ
    save();
  }

  // プレイヤー名
  private static var _name:String = "player";
  public static function getName():String {
    return _name;
  }
  public static function setName(s:String):Void {
    _name = s;
  }

  /**
   * セーブデータが存在するかどうか
   **/
  private static function exists():Bool {
    var saveutil = new FlxSave();
    saveutil.bind("GAMEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.name == null) {
      return false;
    }

    return true;
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("GAMEDATA");
    saveutil.erase();
  }

  /**
   * セーブの実行
   **/
  public static function save():Void {
    var saveutil = new FlxSave();
    saveutil.bind("GAMEDATA");
    saveutil.data.name = _name;
    // 書き込み
    saveutil.flush();
  }

  /**
   * ロードの実行
   **/
  public static function load():Void {
    if(exists()) {
      // 名前を設定
      var saveutil = new FlxSave();
      saveutil.bind("GAMEDATA");
      _name = saveutil.data.name;
    }
  }

  // スコア送信
  public static function sendScore() {
    var user = GameData.getName();
    var score = Global.getScore();
    var floor = Global.getFloor();
    var death = CauseOfDeathMgr.getMessage();
    var data = 'user_name=${user}&score=${score}&floor=${floor}&death=${death}';
    flash.external.ExternalInterface.call("SendScore", data);
  }

}
