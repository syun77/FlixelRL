package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import jp_2dgames.game.event.EventNpc;
import jp_2dgames.game.event.EventScript;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState{

  var _script:EventScript;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // スクリプト生成
    _script = new EventScript("assets/events/", "ending.cpp");
    this.add(_script);
    // NPC生成
    EventNpc.parent = new FlxTypedGroup<EventNpc>(32);
    for(i in 0...EventNpc.parent.maxSize) {
      var npc = new EventNpc();
      npc.ID = 1000 + i;
      this.add(npc);
      EventNpc.parent.add(npc);
    }
    // UI登録
    this.add(_script.ui);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    EventNpc.parent = null;
    EventNpc.isCollision = null;
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _script.proc();
    if(_script.isEnd()) {
      FlxG.switchState(new EndingState());
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
      FlxG.switchState(new EndingState());
    }
  }
}
