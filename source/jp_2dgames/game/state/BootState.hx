package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.FlxState;

/**
 * ゲーム起動時に一度だけ呼び出されるクラス
 **/
class BootState extends FlxState {
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // セーブデータのロード
    GameData.init();
    GameData.load();
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
  #if flash
    FlxG.switchState(new NameEntryState());
  #else
//    FlxG.switchState(new NameEntryState());
    FlxG.switchState(new PlayInitState());
//    FlxG.switchState(new TitleState());
  #end

    super.update();
  }
}
