package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム初期化画面
 **/
class PlayInitState extends FlxState {
  private var _csv:Csv;

  /**
   * 生成
   **/
  override public function create():Void {
    _csv = new Csv();
    NightmareMgr.instance = new NightmareMgr(_csv.enemy_nightmare);

    // ゲームデータを初期化
    Global.init();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    NightmareMgr.instance = null;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // メインゲーム開始
    FlxG.switchState(new PlayState());
  }
}
