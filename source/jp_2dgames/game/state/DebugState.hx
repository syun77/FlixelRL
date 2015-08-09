package jp_2dgames.game.state;
import flixel.text.FlxText;
import jp_2dgames.game.state.TitleState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;
  }
}

/**
 * デバッグ部屋
 **/
class DebugState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // カーソル表示
    FlxG.mouse.visible = true;

    var txt = new FlxText(8, 8, 256, "*DEBUG ROOM*", 20);
    this.add(txt);

    // 各種ボタン
    var px = FlxG.width/2 - 100;
    var py = 128;

    this.add(new MyButton(px, py, "OPENING", function(){ FlxG.switchState(new OpeningState()); }));
    py += 64;
    this.add(new MyButton(px, py, "ENDING", function(){ FlxG.switchState(new EndingState()); }));
    py += 64;
    this.add(new MyButton(px, py, "CREDIT", function(){ FlxG.switchState(new StaffrollState()); }));
    py += 64;
    this.add(new MyButton(px, py, "RESET", function(){
      Save.erase();
      GameData.erase();
      FlxG.resetGame();
    }));
    py += 64;
    this.add(new MyButton(px, py, "TITLE", function(){ FlxG.switchState(new TitleState()); }));
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
