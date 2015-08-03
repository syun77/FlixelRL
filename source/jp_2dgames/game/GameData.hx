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
    // フラグ作成
    _bits = [for(i in 0...BIT_MAX) false];
    // ハイスコア
    _hiscore = 0;

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

  // 汎用フラグ
  private static inline var BIT_MAX:Int = 32;

  // フラグ番号
  public static inline var FLG_FIRST_DONE:Int      = 0; // 初回起動フラグ
  public static inline var FLG_FIRST_GAME_DONE:Int = 1; // 初回ゲームプレイ

  private static var _bits:Array<Bool>;
  public static function bitCheck(idx:Int):Bool {
    if(idx < 0 || BIT_MAX <= idx) {
      return false;
    }
    return _bits[idx];
  }
  public static function bitOn(idx:Int):Void {
    if(idx < 0 || BIT_MAX <= idx) {
      return;
    }
    _bits[idx] = true;
    // セーブ
    save();
  }

  // ハイスコア
  private static var _hiscore:Int = 0;
  public static function getHiscore():Int {
    return _hiscore;
  }
  // 指定のスコアがハイスコアを超えているかどうか
  public static function checkHiscore(v:Int):Bool {
    return v > _hiscore;
  }
  // ハイスコアを更新
  public static function updateHiscore(v:Int):Bool {
    if(v > _hiscore) {
      // ハイスコア更新
      _hiscore = v;
      // セーブする
      save();
      return true;
    }

    // 更新しない
    return false;
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
    saveutil.data.name    = _name;
    saveutil.data.bits    = _bits;
    saveutil.data.hiscore = _hiscore;

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
      if(saveutil.data.bits == null) {
        // フラグがない場合は作成
        _bits = [for(i in 0...BIT_MAX) false];
      }
      else {
        _bits = new Array<Bool>();
        var idx:Int = 0;
        var bits:Array<Bool> = saveutil.data.bits;
        for(bit in bits) {
          _bits[idx] = bit;
          idx++;
        }
      }
      if(saveutil.data.hiscore == null) {
        // ハイスコアがない場合も作成
        _hiscore = 0;
      }
      else {
        _hiscore = saveutil.data.hiscore;
      }
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

    // ハイスコア更新
    updateHiscore(score);
  }

}
