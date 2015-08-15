package jp_2dgames.game.state;
import jp_2dgames.game.save.PlayData;
import jp_2dgames.game.save.GameData;
import flixel.text.FlxText;
import jp_2dgames.game.util.BgWrap;
import flixel.FlxG;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = OnEnter;
    leaveCallback = OnLeave;
  }
}

/**
 * プレイデータ閲覧画面
 **/
class StatisticsState extends FlxState {

  private static inline var TEXT_X = 32;
  private static inline var TEXT_Y = 32;
  private static inline var TEXT_DY = 24;

  private var _txtList:List<FlxText>;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap(false));

    // 情報テキスト
    _txtList = new List<FlxText>();
    var dat:PlayData = GameData.getPlayData();

    var px = TEXT_X;
    var py = TEXT_Y;
    createFlxText(px, py, Std.int(dat.playtime));
    py += TEXT_DY;
    createFlxText(px, py, dat.cntPlay);

    // BACK
    var BACK_X = FlxG.width/2 - 100;
    var BACK_Y = FlxG.height - 64;
    this.add(new MyButton(BACK_X, BACK_Y, "BACK", function() {
      // Statsトップに戻る
      FlxG.switchState(new StatsState());
    }));
  }

  /**
   * テキスト作成
   **/
  private function createFlxText(px:Float, py:Float, info:Dynamic):FlxText {
    var txt = new FlxText(px, py, 640);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    txt.text = '情報: ${info}';
    _txtList.add(txt);
    this.add(txt);
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
  }
}
