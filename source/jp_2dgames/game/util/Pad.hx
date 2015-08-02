package jp_2dgames.game.util;

import flixel.FlxG;
import flixel.input.gamepad.XboxButtonID;

/**
 * ゲームパッド入力管理
 **/
class Pad {
  public static inline var A:Int = XboxButtonID.A;
  public static inline var B:Int = XboxButtonID.B;
  public static inline var X:Int = XboxButtonID.X;
  public static inline var Y:Int = XboxButtonID.Y;

  public static inline var DIR_START:Int = 10000;
  public static inline var LEFT:Int  = DIR_START + 0;
  public static inline var UP:Int    = DIR_START + 1;
  public static inline var RIGHT:Int = DIR_START + 2;
  public static inline var DOWN:Int  = DIR_START + 3;

  public static inline var BUTTON_X_AXIS = XboxButtonID.LEFT_ANALOGUE_X;
  public static inline var BUTTON_Y_AXIS = XboxButtonID.LEFT_ANALOGUE_Y;

  public static inline var BUTTON_AXIS_THRESHOLD:Float = 0.7;

  private static var _prevList:Array<Bool> = null;
  private static var _pressList:Array<Bool> = null;
  public static function update():Void {
    if(_pressList == null) {
      _prevList = [for(i in 0...4) false];
    }
    if(_pressList == null) {
      _pressList = [for(i in 0...4) false];
    }

    for(i in 0...4) {
      _pressList[i] = false;
      var idx = i + DIR_START;
      if(_prevList[i] == false && on(idx)) {
        _pressList[i] = true;
      }
      _prevList[i] = on(idx);
    }
  }

  public static function on(buttonID:Int):Bool {
    var pad = FlxG.gamepads.lastActive;
    if(pad == null) {
      return false;
    }

    switch(buttonID) {
      case Pad.LEFT:
        var xAxis = pad.getXAxis(Pad.BUTTON_X_AXIS);
        return xAxis < -Pad.BUTTON_AXIS_THRESHOLD;
      case Pad.UP:
        var yAxis = pad.getXAxis(Pad.BUTTON_Y_AXIS);
        return yAxis < -Pad.BUTTON_AXIS_THRESHOLD;
      case Pad.RIGHT:
        var xAxis = pad.getXAxis(Pad.BUTTON_X_AXIS);
        return xAxis > Pad.BUTTON_AXIS_THRESHOLD;
      case Pad.DOWN:
        var yAxis = pad.getXAxis(Pad.BUTTON_Y_AXIS);
        return yAxis > Pad.BUTTON_AXIS_THRESHOLD;
      default:
        return pad.pressed(buttonID);
    }
  }

  public static function press(buttonID:Int):Bool {
    var pad = FlxG.gamepads.lastActive;
    if(pad == null) {
      return false;
    }

    switch(buttonID) {
      case Pad.LEFT, Pad.UP, Pad.RIGHT, Pad.DOWN:
        if(_pressList == null) {
          return false;
        }
        return _pressList[buttonID-DIR_START];
      default:
        return pad.justPressed(buttonID);
    }
  }

}

