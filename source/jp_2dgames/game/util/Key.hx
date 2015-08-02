package jp_2dgames.game.util;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;
import flixel.FlxG;

class KeyOn {
  public function new() {}

  public var LEFT(get, never):Bool;

  inline function get_LEFT() {
    if(FlxG.keys.pressed.LEFT) {
      return true;
    }
    if(Pad.on(Pad.LEFT)) {
      return true;
    }
    return false;
  }
  public var RIGHT(get, never):Bool;

  inline function get_RIGHT() {
    if(FlxG.keys.pressed.RIGHT) {
      return true;
    }
    if(Pad.on(Pad.RIGHT)) {
      return true;
    }
    return false;
  }
  public var UP(get, never):Bool;

  inline function get_UP() {
    if(FlxG.keys.pressed.UP) {
      return true;
    }
    if(Pad.on(Pad.UP)) {
      return true;
    }
    return false;
  }
  public var DOWN(get, never):Bool;

  inline function get_DOWN() {
    if(FlxG.keys.pressed.DOWN) {
      return true;
    }
    if(Pad.on(Pad.DOWN)) {
      return true;
    }
    return false;
  }
  public var A(get, never):Bool;

  inline function get_A() {
    if(Key.checkA(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.A)) {
      return true;
    }
    return false;
  }
  public var B(get, never):Bool;

  inline function get_B() {
    if(Key.checkB(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.B)) {
      return true;
    }
    return false;
  }
  public var X(get, never):Bool;

  inline function get_X() {
    if(Key.checkX(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.X)) {
      return true;
    }
    return false;
  }
  public var Y(get, never):Bool;

  inline function get_Y() {
    if(Key.checkY(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.Y)) {
      return true;
    }
    return false;
  }
}

class KeyPress {
  public function new() {}

  public var LEFT(get, never):Bool;

  inline function get_LEFT() {
    if(FlxG.keys.justPressed.LEFT) {
      return true;
    }
    if(Pad.press(Pad.LEFT)) {
      return true;
    }
    return false;
  }
  public var RIGHT(get, never):Bool;

  inline function get_RIGHT() {
    if(FlxG.keys.justPressed.RIGHT) {
      return true;
    }
    if(Pad.press(Pad.RIGHT)) {
      return true;
    }
    return false;
  }
  public var UP(get, never):Bool;

  inline function get_UP() {
    if(FlxG.keys.justPressed.UP) {
      return true;
    }
    if(Pad.press(Pad.UP)) {
      return true;
    }
    return false;
  }
  public var DOWN(get, never):Bool;

  inline function get_DOWN() {
    if(FlxG.keys.justPressed.DOWN) {
      return true;
    }
    if(Pad.press(Pad.DOWN)) {
      return true;
    }
    return false;
  }
  public var A(get, never):Bool;

  inline function get_A() {
    if(Key.checkA(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.A)) {
      return true;
    }
    return false;
  }
  public var B(get, never):Bool;

  inline function get_B() {
    if(Key.checkB(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.B)) {
      return true;
    }
    return false;
  }
  public var X(get, never):Bool;

  inline function get_X() {
    if(Key.checkX(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.X)) {
      return true;
    }
    return false;
  }
  public var Y(get, never):Bool;

  inline function get_Y() {
    if(Key.checkY(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.Y)) {
      return true;
    }
    return false;
  }
}

/**
 * キー入力管理
 **/
class Key {
  public static var on:KeyOn = new KeyOn();
  public static var press:KeyPress = new KeyPress();

  public static function checkA(k:FlxKeyList):Bool {
    if(k.check(FlxKey.ENTER)) {
      return true;
    }
    if(k.check(FlxKey.Z)) {
      return true;
    }
    return false;
  }

  public static function checkB(k:FlxKeyList):Bool {
    if(k.check(FlxKey.SHIFT)) {
      return true;
    }
    if(k.check(FlxKey.X)) {
      return true;
    }
    return false;
  }

  public static function checkX(k:FlxKeyList):Bool {
    if(k.check(FlxKey.SPACE)) {
      return true;
    }
    if(k.check(FlxKey.C)) {
      return true;
    }
    return false;
  }

  public static function checkY(k:FlxKeyList):Bool {
    if(k.check(FlxKey.V)) {
      return true;
    }
    return false;
  }
}
