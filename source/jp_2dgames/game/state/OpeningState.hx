package jp_2dgames.game.state;
import jp_2dgames.game.event.EventMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * オープニング画面
 **/
class OpeningState extends FlxState {

  // イベント管理
  var _event:EventMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // イベント開始
    _event = new EventMgr("assets/events/", "opening.cpp");
    this.add(_event);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(_event.isEnd()) {
      FlxG.switchState(new PlayInitState());
    }

    // デバッグ処理
#if debug
    updateDebug();
#end
  }

  private function updateDebug():Void {
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
    // デバッグ処理
    if(FlxG.keys.justPressed.R) {
      FlxG.switchState(new OpeningState());
    }
  }
}
