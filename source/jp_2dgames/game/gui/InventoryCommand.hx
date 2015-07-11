package jp_2dgames.game.gui;
import flixel.util.FlxAngle;
import jp_2dgames.lib.Snd;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * 状態
 **/
private enum State {
  Main; // 選択中
  End;
  // おしまい
}

/**
 * インベントリのサブメニュー
 **/
class InventoryCommand extends FlxSpriteGroup {

  // ウィンドウサイズ
  private static inline var WIDTH = 64;
  private static inline var DY = 26;
  private static inline var CURSOR_HEIGHT = DY;

  // 背景
  private var _bgList:Array<FlxSprite>;

  // テキスト
  private var _txtList:List<FlxText>;

  // カーソル
  private var _cursor:FlxSprite;
  private var _nCursor:Int = 0;
  public var cursor(get_cursor, null):Int;

  private function get_cursor() {
    return _nCursor;
  }
  private var _tCursor:Int = 0;

  // 項目決定時のコールバック関数
  private var _cbFunc:Int->Int;
  // 項目パラメータ
  private var _items:Array<Int>;

  // 状態
  private var _state:State = State.Main;

  /**
   * コンストラクタ
   * @param X 基準座標(X)
   * @param Y 基準座標(Y)
   * @param cbFunc 項目決定時のコールバック関数
   * @param items 項目パラメータ
   **/
  public function new(X:Float, Y:Float, cbFunc:Int->Int, items:Array<Int>) {
    var ofsY = -Y*2;
    super(X, Y+ofsY);
    FlxTween.tween(this, {y:Y}, 0.3, {ease:FlxEase.expoOut});

    // 背景枠
    _bgList = new Array<FlxSprite>();
    for(i in 0...items.length) {
      var bg = new FlxSprite(0, i * DY, "assets/images/ui/itemcommand.png");
      bg.color = Reg.COLOR_LISTITEM_ENABLE;
      _bgList.push(bg);
      this.add(bg);
    }

    // カーソル
    _cursor = new FlxSprite(0, 0, "assets/images/ui/itemcommand.png");
    _cursor.color = Reg.COLOR_COMMAND_CURSOR;
    this.add(_cursor);

    // メニューテキスト設定
    var i:Int = 0;
    _txtList = new List<FlxText>();
    for(item in items) {
      var px = 0;
      var py = 0 + (i * DY);
      var txt = new FlxText(px, py, 0, WIDTH);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      txt.text = UIText.getText(item);
      txt.color = Reg.COLOR_COMMAND_TEXT_UNSELECTED;
      _txtList.add(txt);
      this.add(txt);
      i++;
    }
    _items = items;
    _cbFunc = cbFunc;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    var i = 0;
    for(txt in _txtList) {
      if(i == _nCursor) {
        txt.color = Reg.COLOR_COMMAND_TEXT_SELECTED;
      }
      else {
        txt.color = Reg.COLOR_COMMAND_TEXT_UNSELECTED;
      }
      i++;
    }

    // カーソル更新
    _tCursor += 4;
    _cursor.alpha = 0.9 + 0.1 * Math.sin(_tCursor * FlxAngle.TO_RAD);
  }

  /**
	 * 更新
	 * @return 項目決定したらfalseを返す
	 **/
  public function proc():Bool {

    switch(_state) {
      case State.Main:
        // カーソル更新
        _procCursor();
        if(Key.press.A) {
          // 項目を決定
          _cbFunc(_items[_nCursor]);
          _state = State.End;
        }

      case State.End:
        // 何もしない
        return false;
    }

    return true;
  }

  /**
	 * カーソル更新
	 **/
  private function _procCursor():Void {
    if(Key.press.UP) {
      Snd.playSe("pi", true);
      _nCursor--;
      if(_nCursor < 0) {
        _nCursor = _txtList.length - 1;
      }
    }
    if(Key.press.DOWN) {
      Snd.playSe("pi", true);
      _nCursor++;
      if(_nCursor >= _txtList.length) {
        _nCursor = 0;
      }
    }
    // カーソルの座標を更新
    _cursor.y = y + (_nCursor * DY);
  }
}
