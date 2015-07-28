package jp_2dgames.game.state;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.text.FlxText;
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
 * タイトル画面
 **/
class TitleState extends FlxState{

  private var _txt:FlxText;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    _txt = new FlxText(32, 32, 128);
    _txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    _txt.text = "タイトル画面";
    this.add(_txt);

    var px = FlxG.width/2 - 100;
    var py = 128;
    this.add(new MyButton(px, py, "NEW GAME", function(){ FlxG.switchState(new PlayInitState()); }));
    py += 64;
    var btnContinue = new MyButton(px, py, "CONTINUE", function() {
      // セーブデータから読み込み
      Global.SetLoadGame(true);
      FlxG.switchState(new PlayState());
    });
    if(Save.isContinue()) {
      py += 64;
      this.add(btnContinue);
    }
    this.add(new MyButton(px, py, "OPENING", function(){ FlxG.switchState(new OpeningState()); }));
    py += 64;
    this.add(new MyButton(px, py, "ENDING", function(){ FlxG.switchState(new EndingState()); }));
    py += 64;
    this.add(new MyButton(px, py, "RESET", function(){
      Save.erase();
      btnContinue.kill();
    }));
    py += 64;
    this.add(new MyButton(px, py, "NAME ENTRY", function(){ FlxG.switchState(new NameEntryState()); }));
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

  #if debug
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminaite.";
    }
  #end
  }
}
