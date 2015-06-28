package jp_2dgames.game.gui;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

private enum State {
  Main;   // メイン
  Closed; // 閉じた
}

/**
 * 購入メニュー
 **/
class GuiBuyDetail extends FlxSpriteGroup {

  // アイテムの最大数
  private static inline var ITEM_MAX:Int = 8;

  // 背景の枠
  private static inline var BG_WIDTH = 200;
  private static inline var BG_HEIGHT = 100;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = 16;
  private static inline var MSG_Y = 8;
  private static inline var MSG_DY = 24;

  // インスタンス
  private static var _instance:GuiBuyDetail = null;

  // テキストリスト
  private var _txtList:Array<FlxText>;

  // カーソル
  private var _cursor:FlxSprite;
  private var _nCursor:Int;

  // 状態
  private var _state:State = State.Main;

  /**
   * 閉じたかどうか
   **/
  public static function isClosed():Bool {
    return _instance == null;
  }

  /**
   * 開く
   **/
  public static function open(X:Float, Y:Float):Void {
    _instance = new GuiBuyDetail(X, Y);
    FlxG.state.add(_instance);
  }

  /**
   * コンストラクタ
   */
  public function new(X:Float, Y:Float) {
    super(X, Y);

    // 背景
    var back = FlxSprite(0, 0).makeGraphic(BG_WIDTH, BG_HEIGHT, FlxColor.BLACK);
    back.alpha = 0.5;
    this.add(back);

    // テキスト
    _txtList = new Array<FlxText>();
    var px = MSG_X;
    var py = MSG_Y;
    for(i in 0...ITEM_MAX) {
      var txt = new FlxText(px, py, TXT_WIDTH);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      py += MSG_DY;
      this.add(txt);
      _txtList.push(txt);
    }

    // カーソル
    _cursor = new FlxSprite(MSG_X, MSG_Y);
    _cursor.makeGraphic(128, 24, FlxColor.AQUAMARINE);
    _cursor.alpha = 0.3;
    this.add(_cursor);

    _nCursor = 0;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        if(Key.press.UP) {
          _nCursor--;
          if(_nCursor < 0) {
            _nCursor = ITEM_MAX - 1;
          }
        }
        else if(Key.press.DOWN) {
          _nCursor++;
          if(_nCursor >= ITEM_MAX) {
            _nCursor = 0;
          }
        }

        // カーソル更新
        _updateCursor();

        if(Key.press.A) {
          _state = State.Closed;
          FlxG.state.remove(this);
          _instance = null;
        }

      case State.Closed:
    }
  }

  /**
   * カーソルの更新
   **/
  private function _updateCursor():Void {

  }
}
