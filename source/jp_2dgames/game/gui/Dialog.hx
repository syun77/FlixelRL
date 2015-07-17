package jp_2dgames.game.gui;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.util.MyColor;
import jp_2dgames.game.util.Key;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

private enum State {
  Main;   // メイン
  Closed; // 閉じた
}

/**
 * ダイアログ
 **/
class Dialog extends FlxGroup {
  // ダイアログの種類
  public static inline var OK:Int = 0; // OKダイアログ
  public static inline var YESNO:Int = 1; // Yes/Noダイアログ
  public static inline var SELECT2:Int = 2; // 2択ダイアログ
  public static inline var SELECT3:Int = 3; // 3択ダイアログ

  // 3択ダイアログのオフセット座標(Y)
  private static inline var SELECT3_OFS_Y:Int = 24;

  // インスタンス
  private static var _instance:Dialog = null;
  // カーソル番号
  private static var _nCursor:Int = 0;

  public static function getCursor():Int {
    return _nCursor;
  }

  // ダイアログの種類
  private var _type:Int;
  // 状態
  private var _state:State = State.Main;
  public var state(get, null):State;

  private function get_state() {
    return _state;
  }
  // カーソル
  private var _cursor:FlxSprite = null;
  // カーソルの最大
  private var _cursorMax:Int = 0;

  /**
   * 閉じたかどうか
   **/
  public static function isClosed():Bool {
    return _instance.state == State.Closed;
  }

  /**
   * 開く
   **/
  public static function open(type:Int, msg:String, sels:Array<String>=null):Void {
    _instance = new Dialog(type, msg, sels);
    FlxG.state.add(_instance);
    _nCursor = 0;
  }

  /**
	 * コンストラクタ
	 **/

  private function new(type:Int, msg:String, sels:Array<String>) {
    super();

    var px = Reg.centerX();
    var py = Reg.centerY();
    var height = 64;
    if(type == SELECT3) {
      // 広げる
      height += SELECT3_OFS_Y;
    }
    // ウィンドウ
    var spr = new FlxSprite(px, py - height);
    this.add(spr);

    // メッセージ
    var text = new FlxText(px, py - 48, 0, 96);
    text.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    text.text = msg;
    // 中央揃え
    var width = text.textField.width;
    text.x = px - width / 2;
    this.add(text);

    // ウィンドウサイズを設定
    spr.makeGraphic(Std.int(width * 2), height * 2, FlxColor.WHITE);
    spr.color = MyColor.MESSAGE_WINDOW;
    spr.x -= width;
    spr.alpha = 0.5;
    spr.scale.set(0.2, 1);
    FlxTween.tween(spr.scale, {x:1}, 0.2, {ease:FlxEase.expoOut});

    // ウィンドウ飾り
    {
      var bg1 = new FlxSprite(px, py - height, "assets/images/ui/frame32x256.png");
      bg1.color = MyColor.MESSAGE_WINDOW;
      bg1.scale.set(1, height*2/256);
      bg1.x -= bg1.width;
      bg1.y -= height;
      if(type == SELECT3) {
        bg1.y += SELECT3_OFS_Y*2;
      }
      this.add(bg1);
      FlxTween.tween(bg1, {x:bg1.x-width}, 0.2, {ease:FlxEase.expoOut});

      var bg2 = new FlxSprite(px, py - height, "assets/images/ui/frame32x256.png");
      bg2.color = MyColor.MESSAGE_WINDOW;
      bg2.scale.set(1, height*2/256);
      bg2.flipX = true;
      bg2.y -= height;
      if(type == SELECT3) {
        bg2.y += SELECT3_OFS_Y*2;
      }
      this.add(bg2);
      FlxTween.tween(bg2, {x:bg2.x+width}, 0.2, {ease:FlxEase.expoOut});
    }

    // 選択肢
    var py2 = FlxG.height / 2;
    _type = type;
    var labels:Array<String> = [];
    switch(_type) {
      case OK:
        labels = ["OK"];
        _cursorMax = 1;
      case YESNO:
        labels = ["はい", "いいえ"];
        _cursorMax = 2;
      case SELECT2:
        labels = sels;
        _cursorMax = 2;

      case SELECT3:
        labels = sels;
        _cursorMax = 3;
    }

    // 選択肢登録
    for(str in labels) {
      var txt = new FlxText(px, py2, 0, 128);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      txt.text = str;
      // センタリング
      txt.x -= txt.textField.width/2;
      this.add(txt);
      py2 += 24;
    }

    // カーソル
    if(_type == SELECT3) {
      _cursor = new FlxSprite(px, py2);
      _cursor.makeGraphic(128, 24, FlxColor.AQUAMARINE);
      _cursor.alpha = 0.3;
    }
    else {
      _cursor = new FlxSprite(px, py2);
      _cursor.makeGraphic(84, 24, FlxColor.AQUAMARINE);
      _cursor.alpha = 0.3;
    }
    this.add(_cursor);

    Snd.playSe("menu");
  }

  /**
	 * 更新
	 **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        if(Key.press.LEFT || Key.press.UP) {
          Snd.playSe("pi", true);
          _nCursor--;
          if(_nCursor < 0) {
            _nCursor = _cursorMax - 1;
          }
        }
        else if(Key.press.RIGHT || Key.press.DOWN) {
          Snd.playSe("pi", true);
          _nCursor++;
          if(_nCursor >= _cursorMax) {
            _nCursor = 0;
          }
        }
        _updataeCursor();

        if(Key.press.A) {
          // 決定
          _state = State.Closed;
          FlxG.state.remove(this);
        }
        else if(Key.press.B) {
          // キャンセル
          _nCursor = -1;
          _state = State.Closed;
          FlxG.state.remove(this);
        }

      case State.Closed:

    }
  }

  /**
	 * カーソル位置の更新
	 **/

  private function _updataeCursor():Void {
    var px = Reg.centerX();
    _cursor.x = px - _cursor.width/2;
    var py2 = Reg.centerY();
    _cursor.y = py2 + 24 * _nCursor;
  }
}
