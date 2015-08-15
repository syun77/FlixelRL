package jp_2dgames.game.state;
import jp_2dgames.game.util.BgWrap;
import flixel.addons.ui.FlxButtonPlus;
import jp_2dgames.game.util.Key;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.playlog.PlayLogData;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.game.playlog.PlayLog;
import flixel.text.FlxText;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, W:Int = 200, H:Int = 40, ?Text:String, ?OnClick:Void->Void) {
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, W, H);
    textNormal.size = s;
    textHighlight.size = s;
  }
}

/**
 * プレイログ画面
 **/
class PlayLogState extends FlxState {

  private static inline var PAGE_DISP_MAX:Int = 12;

  private static inline var PAGE_X = 32;
  private static inline var PAGE_Y = 16;
  private static inline var POS_X = 32;
  private static inline var POS_Y = 64;
  private static inline var POS_DY = 32;

  private static inline var BTN_PREV_X = 256;
  private static inline var BTN_PREV_Y = 16;
  private static inline var BTN_NEXT_X = BTN_PREV_X + BTN_WIDTH + 16;
  private static inline var BTN_NEXT_Y = BTN_PREV_Y;
  private static inline var BTN_WIDTH:Int  = 40;
  private static inline var BTN_HEIGHT:Int = 32;

  private var _txtList:List<FlxText>;

  // 現在のページ数
  private var _nPage:Int;
  // 最大ページ数
  private var _maxPage:Int;
  // ページ情報
  private var _txtPage:FlxText;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap());

    // カーソル表示
    FlxG.mouse.visible = true;

    _nPage = 0;
    _maxPage = Math.ceil(PlayLog.count() / PAGE_DISP_MAX);

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
    var btnBack = new MyButton(FlxG.width/2 - 100, FlxG.height-64, 200, 40, "BACK", function() {
      FlxG.switchState(new TitleState());
    });
    this.add(btnBack);
  }

  /**
   * ログ消去
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

      var idx = (i + PAGE_DISP_MAX * _nPage);
      var log = PlayLog.getLogReverse(idx);
      if(log == null) {
        break;
      }
      var txt = _addLog(i, log);
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

  /**
   * ログの追加
   **/
  private function _addLog(idx:Int, log:PlayLogData):FlxText {
    var txt = new FlxText(POS_X, POS_Y+POS_DY*idx, FlxG.width);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);

    var hour = TextUtil.fillZero(Std.int(log.playtime/60/60), 2);
    var min  = TextUtil.fillZero(Std.int(log.playtime/60), 2);
    var sec  = TextUtil.fillZero(log.playtime%60, 2);
    var str = '';
//    str += '[${hour}:${min}:${sec}]';
    str += '[${log.date}]';
    str += ' Lv:${log.lv}';
    str += ' ${log.floor}F';
    str += ' ${log.score}pt';
    str += ' ${log.death}';

    txt.text = str;

    return txt;
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(Key.press.LEFT) {
      // ページ戻る
      _changePage(-1);
    }
    else if(Key.press.RIGHT) {
      // ページ進める
      _changePage(1);
    }

    if(Key.press.A || Key.press.B) {
      // タイトル画面に戻る
      FlxG.switchState(new TitleState());
    }

#if debug
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
#end
  }
}
