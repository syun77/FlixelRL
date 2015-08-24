package jp_2dgames.game.state;
import jp_2dgames.game.save.GameData;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.unlock.UnlockMgr;
import jp_2dgames.game.util.BgWrap;
import jp_2dgames.game.util.Key;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, W:Int = 200, H:Int = 40, ?Text:String, ?OnClick:Void->Void) {
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, W, H);
    textNormal.size = s;
    textHighlight.size = s;
  }
}

/**
 * アチーブメント画面
 **/
class AchievementState extends FlxState {

  // 1画面に表示する項目の数
  private static inline var PAGE_DISP_MAX:Int = 10;

  // 座標関連
  private static inline var PAGE_X = 32;
  private static inline var PAGE_Y = 16;
  private static inline var POS_X = 64;
  private static inline var POS_Y = 64;
  private static inline var POS_DY = 32;
  // 詳細情報
  private static inline var DETAIL_X = POS_X;
  private static inline var DETAIL_Y = 416+8;

  // ボタン
  /// 1つ戻る
  private static inline var BTN_PREV_X = 320; // X座標
  private static inline var BTN_PREV_Y = 16;  // Y座標
  /// 1つ進む
  private static inline var BTN_NEXT_X = BTN_PREV_X + BTN_WIDTH + 16; // X座標
  private static inline var BTN_NEXT_Y = BTN_PREV_Y; // Y座標
  // ボタンの幅
  private static inline var BTN_WIDTH:Int  = 40;
  private static inline var BTN_HEIGHT:Int = 32;

  // ■メンバ変数
  private var _txtList:List<FlxText>;

  // 現在のページ数
  private var _nPage:Int;
  // 最大ページ数
  private var _maxPage:Int;
  // ページ情報
  private var _txtPage:FlxText;

  // カーソル
  private var _cursor:FlxSprite;

  // 詳細呪法
  private var _txtDetail:FlxText;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    this.add(new BgWrap(false));

    // カーソル
    _cursor = new FlxSprite();
    _cursor.makeGraphic(FlxG.width, 32, FlxColor.YELLOW);
    _cursor.alpha = 0.1;
    this.add(_cursor);
    FlxTween.tween(_cursor, {alpha:0.3}, 2, {type:FlxTween.PINGPONG, ease:function(v:Float) return v });

    // アンロック管理生成
    UnlockMgr.createInstance();

    _nPage = 0;
    _maxPage = Math.ceil(UnlockMgr.maxSize() / PAGE_DISP_MAX);

    _txtList = new List<FlxText>();
    _txtPage = new FlxText(PAGE_X, PAGE_Y, 256, "", 24);
    this.add(_txtPage);

    _changePage(0);

    // ページ切り替えボタン
    // <<
    var btnPrev = new MyButton(BTN_PREV_X, BTN_PREV_Y, BTN_WIDTH, BTN_HEIGHT, "<<", function() {
      _changePage(-1);
    });
    this.add(btnPrev);
    // >>
    var btnNext = new MyButton(BTN_NEXT_X, BTN_NEXT_Y, BTN_WIDTH, BTN_HEIGHT, ">>", function() {
      _changePage(1);
    });
    this.add(btnNext);

    // 戻るボタン
    var btnBack = new MyButton(FlxG.width/2 + 100, FlxG.height-64, 200, 40, "BACK", function() {
      FlxG.switchState(new StatsState());
    });
    this.add(btnBack);

    // 詳細情報
    _txtDetail = new FlxText(DETAIL_X, DETAIL_Y, 480);
    _txtDetail.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtDetail);

  }

  /**
   * 表示項目消去
   **/
  private function _removeText():Void {
    for(txt in _txtList) {
      this.remove(txt);
    }
    _txtList.clear();
  }

  /**
   * ページ切り替え
   **/
  private function _changePage(ofs:Int):Void {

    if(_nPage + ofs < 0) {
      return;
    }
    if(_nPage + ofs >= _maxPage) {
      return;
    }

    // テキスト消去
    _removeText();

    _nPage += ofs;

    for(i in 0...PAGE_DISP_MAX) {
      // 1始まりなので+1
      var idx = i + (PAGE_DISP_MAX * _nPage) + 1;
      if(idx >= UnlockMgr.maxSize()) {
        break;
      }
      var txt = _addItem(i, idx);
      this.add(txt);
      _txtList.add(txt);

      var px = txt.x;
      if(ofs >= 0) {
        // ページを進める
        txt.x = FlxG.width;
      }
      else {
        // ページ戻る
        txt.x = -FlxG.width;
      }
      FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, startDelay:0.05*i});
    }

    // ページ数更新
    _txtPage.text = 'Page:(${_nPage+1}/${_maxPage})';
  }

  private function _addItem(i:Int, idx:Int):FlxText {
    var txt = new FlxText(POS_X, POS_Y + (POS_DY*i), FlxG.width);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    if(_isUnlock(idx)) {
      txt.text = UnlockMgr.getParam(idx, "name");
    }
    else {
      txt.text = "???";
    }

    return txt;
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    // Unlock管理破棄
    UnlockMgr.destroyInstance();

    super.destroy();
  }

  private function _getCursorIdx():Int {
    var Idx = Std.int((FlxG.mouse.y - POS_Y) / POS_DY);
    if(Idx < 0) { Idx = 0; }
    var max = PAGE_DISP_MAX-1;
    var maxIdx = UnlockMgr.maxSize() - (_nPage * PAGE_DISP_MAX) - 2;
    if(max > maxIdx) {
      max = maxIdx;
    }
    if(Idx > max) { Idx = max; }

    return Idx;
  }
  private function _getCursorIdx2():Int {
    return _getCursorIdx() + 1 + (_nPage * PAGE_DISP_MAX);
  }
  private function _isUnlock(idx:Int):Bool {
    return GameData.getPlayData().flgUnlock.indexOf(idx) != -1;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // カーソル座標更新
    {
      var px = 0;//POS_X;
      var py = POS_Y;
      var Idx = _getCursorIdx();
      py += Idx * POS_DY;
      _cursor.x = px;
      _cursor.y = py;
    }

    // 詳細情報更新
    {
      var idx = _getCursorIdx2();
      if(_isUnlock(idx) == false) {
        _txtDetail.text = "HINT: " + UnlockMgr.getParam(idx, "cond");
      }
    }

    if(Key.press.LEFT) {
      // ページ戻る
      _changePage(-1);
    }
    else if(Key.press.RIGHT) {
      // ページ進める
      _changePage(1);
    }

    if(Key.press.A || Key.press.B) {
      // Statトップ画面に戻る
      FlxG.switchState(new StatsState());
    }

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
