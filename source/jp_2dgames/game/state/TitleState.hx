package jp_2dgames.game.state;
import jp_2dgames.game.util.Key;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

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

    if(Key.press.A) {
      // メインゲーム画面に進む
      FlxG.switchState(new PlayState());
    }
  }
}
