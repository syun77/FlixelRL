package jp_2dgames.game.gui;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
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
  public static inline var ITEM_MAX:Int = 8;

  // 背景の枠
  public static inline var BG_WIDTH = 280;
  public static inline var BG_HEIGHT = MSG_Y*2 + ITEM_MAX*MSG_DY;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = 16;
  private static inline var MSG_Y = 8;
  private static inline var MSG_DY = 24;

  // インスタンス
  private static var _instance:GuiBuyDetail = null;

  // テキストリスト
  private var _txtList:Array<FlxText>;
  // アイテムリスト
  private var _itemList:Array<ItemData>;

  // カーソル
  private var _cursor:FlxSprite;
  private var _nCursor:Int;

  // 状態
  private var _state:State = State.Main;

  /**
   * 閉じたかどうか
   **/
  public static function isClosed():Bool {
    return _instance._state == State.Closed;
  }

  /**
   * 開く
   **/
  public static function open():Void {
    FlxG.state.add(_instance);
    _instance._open();
  }

  /**
   * 開く
   **/
  private function _open():Void {
    _state = State.Main;
    _updateText();
  }

  /**
   * 生成
   **/
  public static function create(X:Float, Y:Float):Void {
    _instance = new GuiBuyDetail(X, Y);
  }

  /**
   * アイテムを追加する
   **/
  public static function addItem(item:ItemData):Void {
    _instance._addItem(item);
  }

  /**
   * アイテムを追加する
   **/
  private function _addItem(item:ItemData):Void {
    _itemList.push(item);
  }

  /**
   * アイテムリストから削除する
   **/
  private function delItem(idx:Int):Void {
    _itemList.splice(idx, 1);
    _updateText();
  }

  /**
   * コンストラクタ
   */
  public function new(X:Float, Y:Float) {
    super(X, Y);

    // 背景
    var back = new FlxSprite(0, 0).makeGraphic(BG_WIDTH, BG_HEIGHT, FlxColor.BLACK);
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

    // アイテムリスト
    _itemList = new Array<ItemData>();

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

        if(Key.press.B) {
          _state = State.Closed;
          FlxG.state.remove(this);
        }

      case State.Closed:
    }
  }

  /**
   * カーソルの更新
   **/
  private function _updateCursor():Void {

  }

  /**
   * 項目テキストの更新
   **/
  private function _updateText():Void {

    // いったんすべてクリア
    for(txt in _txtList) {
      txt.text = "";
    }

    // テキストを設定
    var idx = 0;
    for(item in _itemList) {
      _txtList[idx].text = ItemUtil.getName(item);
      idx++;
    }
  }
}
