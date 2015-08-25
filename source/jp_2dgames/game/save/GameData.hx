package jp_2dgames.game.save;
import jp_2dgames.game.unlock.UnlockMgr;
import jp_2dgames.game.item.ItemUtil;
import flixel.FlxG;
import jp_2dgames.game.playlog.PlayLog;
import jp_2dgames.game.playlog.PlayLogData;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.util.CauseOfDeathMgr;
import flash.external.ExternalInterface;
import jp_2dgames.game.util.NameGenerator;
import flixel.util.FlxSave;
#if flash
// HACK: これを描かないとリフレクションできない
import jp_2dgames.game.util.Auth;
#end

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

  // セーブデータのバージョン番号
  public static var VERSION:String = "Ver 0.9.1";

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
  public static inline var FLG_GAME_CLEAR:Int      = 2; // ゲームクリアフラグ
  public static inline var FLG_FLOOR_ALL:Int       = 3; // 全フロア踏破フラグ

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
  // ハイスコアを更新
  public static function updateHiscore(v:Int):Bool {
    _bNewHiscore = false;

    if(v > _hiscore) {
      // ハイスコア更新
      _bNewHiscore = true;
      _hiscore = v;
      // セーブする
      save();
      return true;
    }

    // 更新しない
    return false;
  }
  // ハイスコアを更新したかどうか
  private static var _bNewHiscore:Bool = false;
  public static function isNewHiscore():Bool {
    return _bNewHiscore;
  }

  // ゲームプレイデータ
  private static var _playdata:PlayData;
  public static function getPlayData():PlayData {
    return _playdata;
  }

  // アイテムログ追加
  public static function addItemLog(itemID:Int):Void {
    var itemFlg = _playdata.flgItemFind;
    if(itemFlg.indexOf(itemID) == -1) {
      // ログに存在しないので追加
      itemFlg.push(itemID);

      // 収集率チェック
      var ratio = ItemUtil.getUnlockRatio(itemFlg);
      // パーセンテージに変換
      var per = Math.floor(ratio * 100);
      UnlockMgr.check("item", per);
    }
  }

  // 敵のログ追加
  public static function addEnemyLog(enemyID:Int):Void {
    var enemyFlg = _playdata.flgEnemyKill;
    if(enemyFlg.indexOf(enemyID) == -1) {
      // ログに存在しないので追加
      enemyFlg.push(enemyID);
    }
  }

  // アンロック追加
  public static function addUnlock(unlockID:Int):Void {
    var unlockFlg = _playdata.flgUnlock;
    if(unlockFlg.indexOf(unlockID) == -1) {
      // 存在しないので追加
      unlockFlg.push(unlockID);
    }
  }

  // アンロック済みかどうかをチェック
  public static function checkUnlock(unlockID:Int):Bool {
    return _playdata.flgUnlock.indexOf(unlockID) != -1;
  }

  /**
   * セーブデータが存在するかどうか
   **/
  private static function exists():Bool {
    var saveutil = new FlxSave();
    saveutil.bind("GAMEDATA");
    if(saveutil.data == null) {
      // データがない
      return false;
    }
    if(saveutil.data.name == null) {
      // ユーザ名が設定されていない
      return false;
    }
    if(saveutil.data.version == null) {
      // バージョン番号がない
      return false;
    }
    if(saveutil.data.version != VERSION) {
      // バージョン番号が一致していない
      return  false;
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
    saveutil.data.version  = VERSION;
    saveutil.data.name     = _name;
    saveutil.data.bits     = _bits;
    saveutil.data.hiscore  = _hiscore;
    saveutil.data.playdata = _playdata;

    // 書き込み
    saveutil.flush();
  }

  /**
   * ロードの実行
   **/
  public static function load():Void {
    if(exists()) {

      // ■名前を設定
      var saveutil = new FlxSave();
      saveutil.bind("GAMEDATA");
      _name = saveutil.data.name;

      // ■フラグ
      if(saveutil.data.bits == null) {
        // フラグデータがない場合は作成
        _bits = [for(i in 0...BIT_MAX) false];
      }
      else {
        // ある場合はセーブデータからコピー
        _bits = new Array<Bool>();
        var idx:Int = 0;
        var bits:Array<Bool> = saveutil.data.bits;
        for(bit in bits) {
          _bits[idx] = bit;
          idx++;
        }
      }

      // ■ハイスコア
      if(saveutil.data.hiscore == null) {
        // ハイスコアがない場合も作成
        _hiscore = 0;
      }
      else {
        _hiscore = saveutil.data.hiscore;
      }

      // ■プレイデータ
      _playdata = new PlayData();
      if(saveutil.data.playdata != null) {
        // セーブデータがあればコピー
        _playdata.copyFromDynamic(saveutil.data.playdata);
      }
    }
  }

  // スコア送信
  public static function sendScore(lv:Int) {

    var user     = GameData.getName();
    var score    = Global.getScore();
    var floor    = Global.getFloor();
    var death    = CauseOfDeathMgr.getMessage();
    var playtime = Std.int(Global.getPlayTime());
    var weapon   = Inventory.getWeaponName();
    var armor    = Inventory.getArmorName();
    var ring     = Inventory.getRingName();

    // 認証キー取得
    var key = "none";
    {
      var type = Type.resolveClass("jp_2dgames.game.util.Auth");
      if(type != null) {
        var obj = Type.createEmptyInstance(type);
        key = Reflect.callMethod(obj, Reflect.field(obj, "generate"), [lv]);
      }
    }
    var data = 'user_name=${user}';
    data += '&score=${score}';
    data += '&floor=${floor}';
    data += '&death=${death}';
    data += '&key=${key}';
    data += '&playtime=${playtime}';
    data += '&lv=${lv}';
    data += '&weapon=${weapon}';
    data += '&armor=${armor}';
    data += '&ring=${ring}';

    data = StringTools.replace(data, "+", "@");
    flash.external.ExternalInterface.call("SendScore", data);

    // ハイスコア更新
    updateHiscore(score);
    // セーブしておく
    save();

    // プレイログ保存
    var log = new PlayLogData();
    log.user     = user;
    log.score    = score;
    log.lv       = lv;
    log.floor    = floor;
    log.death    = death;
    log.playtime = playtime;
    log.date     = Date.now().toString();
    PlayLog.add(log);
    PlayLog.save();
  }
}
