package;

import jp_2dgames.game.state.TitleState;
import jp_2dgames.game.state.EndingState;
import jp_2dgames.game.state.OpeningState;
import jp_2dgames.game.state.PlayInitState;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;

class Main extends Sprite {
  var gameWidth:Int = 426 * 2; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
  var gameHeight:Int = 240 * 2; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
#if flash
  var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
#else
  //  var initialState:Class<FlxState> = OpeningState; // The FlxState the game starts with.
    var initialState:Class<FlxState> = EndingState; // The FlxState the game starts with.
//  var initialState:Class<FlxState> = PlayInitState; // The FlxState the game starts with.
//  var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
#end
  var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
  var framerate:Int = 60; // How many frames per second the game should run at.
  var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
  var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

  // You can pretty much ignore everything from here on - your code should go in your states.

  public static function main():Void {
    Lib.current.addChild(new Main());
  }

  public function new() {
    super();

    if(stage != null) {
      init();
    }
    else {
      addEventListener(Event.ADDED_TO_STAGE, init);
    }
  }

  private function init(?E:Event):Void {
    if(hasEventListener(Event.ADDED_TO_STAGE)) {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    }

    setupGame();
  }

  private function setupGame():Void {
    var stageWidth:Int = Lib.current.stage.stageWidth;
    var stageHeight:Int = Lib.current.stage.stageHeight;

    if(zoom == -1) {
      var ratioX:Float = stageWidth / gameWidth;
      var ratioY:Float = stageHeight / gameHeight;
      zoom = Math.min(ratioX, ratioY);
      gameWidth = Math.ceil(stageWidth / zoom);
      gameHeight = Math.ceil(stageHeight / zoom);
    }

    addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
  }
}