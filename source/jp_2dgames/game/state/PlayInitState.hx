package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム初期化画面
 **/
class PlayInitState extends FlxState {
  override public function create():Void {
    // ゲームデータを初期化
    Global.init();
  }

  override public function update():Void {
    super.update();

    // メインゲーム開始
    FlxG.switchState(new PlayState());
  }
}
