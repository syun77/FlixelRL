package jp_2dgames.game.state;

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
 * アイテムログ画面
 **/
class ItemLogState extends FlxState {

  // 戻るボタン
  private static inline var BACK_X = 600;
  private static inline var BACK_Y = 416;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 戻るボタン
    var btnBack = new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new StatsState());
    });
    this.add(btnBack);
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

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
