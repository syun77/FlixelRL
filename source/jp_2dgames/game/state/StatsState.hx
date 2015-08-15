package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.util.BgWrap;
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
 * 統計メニュートップ画面
 **/
class StatsState extends FlxState {

  private static inline var MENU_Y = 120;
  private static inline var MENU_DY = 64;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // カーソル表示
    FlxG.mouse.visible = true;

    // 背景
    this.add(new BgWrap(false));

    var btnList = new List<MyButton>();

    var px = FlxG.width;
    var py = MENU_Y;

    // STATISTICS
    btnList.add(new MyButton(px, py, "STATISTICS", function() {
      // プレイデータを見る
      FlxG.switchState(new StatisticsState());
    }));

    py += MENU_DY;

    // PLAY LOG
    btnList.add(new MyButton(px, py, "PLAY LOG", function() {
      // PLAY LOGを見る
      FlxG.switchState(new PlayLogState());
    }));

    py += Std.int(MENU_DY * 1.3);
    // BACK
    btnList.add(new MyButton(px, py, "BACK", function() {
      // タイトル画面に戻る
      FlxG.switchState(new TitleState());
    }));

    var px2 = FlxG.width/2 - 100;
    var idx:Int = 0;
    for(btn in btnList) {
      FlxTween.tween(btn, {x:px2}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.1});
      this.add(btn);
      idx++;
    }
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
