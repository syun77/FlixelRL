package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import jp_2dgames.game.event.EventMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState{

  var _event:EventMgr;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // スコア送信
    GameData.sendScore();

    // スクリプト生成
    _event = new EventMgr("assets/events/", "ending.cpp");
    this.add(_event);

    // スキップボタン
    var btn = new FlxButton(FlxG.width-88, -32, "SKIP", function() {
      FlxG.switchState(new TitleState());
    });
    FlxTween.tween(btn, {y:8}, 2, {ease:FlxEase.expoOut});
    this.add(btn);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(_event.isEnd()) {
      FlxG.switchState(new TitleState());
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
