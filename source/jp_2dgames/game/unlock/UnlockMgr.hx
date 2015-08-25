package jp_2dgames.game.unlock;
import jp_2dgames.game.save.GameData;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.lib.CsvLoader;

/**
 * アンロック管理
 **/
class UnlockMgr extends FlxSpriteGroup{

  private static inline var POS_Y = 8;
  private static inline var OFS_X = 8;
  private static inline var OFS_Y = 4;
  private static inline var WIDTH = 320;
  private static inline var HEIGHT = 32;

  private static var _instance:UnlockMgr = null;

  /**
   * インスタンス生成
   **/
  public static function createInstance():UnlockMgr {
    if(_instance == null) {
      _instance = new UnlockMgr();
    }
    return _instance;
  }

  /**
   * インスタンス解放
   **/
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
  public static function maxDataSize():Int {
    return _instance._maxDataSize();
  }
  private function _maxDataSize():Int {
    return _csv.size();
  }

  private var _txt:FlxText;
  private var _queue:List<Int>;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    _csv = new CsvLoader("assets/data/achievement.csv");

    _queue = new List<Int>();

    var bg = new FlxSprite(0, 0).makeGraphic(WIDTH, HEIGHT, FlxColor.BLACK);
    bg.alpha = 0.5;
    this.add(bg);
    var color = FlxColor.SILVER;
    this.add(new FlxSprite(0, 0).makeGraphic(WIDTH, 2, color));
    this.add(new FlxSprite(WIDTH-2, 0).makeGraphic(2, HEIGHT, color));
    this.add(new FlxSprite(0, 0).makeGraphic(2, HEIGHT, color));
    this.add(new FlxSprite(0, HEIGHT-2).makeGraphic(WIDTH, 2, color));

    _txt = new FlxText(OFS_X, OFS_Y, WIDTH);
    _txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txt.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLUE);
    this.add(_txt);

    // 非表示にしておく
    this.visible = false;
  }

  /**
   * キューにアンロック項目を追加
   **/
  private function _enqueue(idx:Int):Void {
    // フラグ登録
    GameData.addUnlock(idx);

    // 保存
    GameData.save();

    _queue.add(idx);
  }

  /**
   * 更新
   **/
  override function update():Void {
    super.update();

    if(this.visible == false) {
      if(_queue.length > 0) {
        var idx = _queue.pop();
        start(idx);
      }
    }
  }

  /**
   * アンロック演出開始
   **/
  private function start(idx:Int):Void {

    // 表示開始
    this.visible = true;
    // テキスト設定
    _txt.text = "Unlock: " + _getParam(idx, "name");

    // アニメーション設定
    var px = FlxG.width - WIDTH - 4;
    var py = POS_Y;
    this.x = FlxG.width;
    this.y = py;
    FlxTween.tween(this, {x:px}, 1, {ease:FlxEase.expoOut, complete:function(tween:FlxTween) {
      new FlxTimer(3, function(timer:FlxTimer) {
        FlxTween.tween(this, {y:-48}, 0.5, {ease:FlxEase.expoIn, complete:function(tween:FlxTween) {
          this.visible = false;
        }});
      });
    }});
  }

  /**
   * アンロックのチェック
   **/
  public static function check(type:String, arg:Int):Void {
    trace(GameData.getPlayData().flgUnlock);
    _instance._check(type, arg);
  }
  private function _check(type:String, arg:Int):Void {
    var size = _maxDataSize();
    for(i in 1...size) {

      if(GameData.checkUnlock(i)) {
        // すでにアンロック済み
        continue;
      }

      var t = _getParam(i, "type");
      if(t != type) {
        continue;
      }

      var param = _getParamInt(i, "param0");
      var bUnlock = false;
      switch(type) {
        case "floor":
          if(arg >= param) {
            bUnlock = true;
          }

        case "orb":
          // オーブを4つ集めた
          if(arg >= param) {
            bUnlock = true;
          }

        case "floor_all":
          // 全フロア踏破
          bUnlock = true;

        case "money":
          // 所持金チェック
          if(arg >= param) {
            bUnlock = true;
          }

        case "item":
          // アイテム収集率
          if(arg >= param) {
            bUnlock = true;
          }

        case "enemy":
          if(param == arg) {
            bUnlock = true;
          }

        case "death":
          if(param == arg) {
            bUnlock = true;
          }
      }

      if(bUnlock) {
        trace("unlock", i);
        _enqueue(i);
      }
    }
  }
}
