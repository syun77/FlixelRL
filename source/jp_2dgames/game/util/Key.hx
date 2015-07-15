package jp_2dgames.game.util;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;
import flixel.FlxG;

class KeyOn {
  public function new() {}
  public var LEFT(get, never):Bool;

  inline function get_LEFT() { return FlxG.keys.pressed.LEFT; }
  public var RIGHT(get, never):Bool;

  inline function get_RIGHT() { return FlxG.keys.pressed.RIGHT; }
  public var UP(get, never):Bool;

  inline function get_UP() { return FlxG.keys.pressed.UP; }
  public var DOWN(get, never):Bool;

  inline function get_DOWN() { return FlxG.keys.pressed.DOWN; }
  public var A(get, never):Bool;

  inline function get_A() { return Key.checkA(FlxG.keys.pressed); }
  public var B(get, never):Bool;

  inline function get_B() { return Key.checkB(FlxG.keys.pressed); }
  public var X(get, never):Bool;

  inline function get_X() { return Key.checkX(FlxG.keys.pressed); }
}

class KeyPress {
  public function new() {}
  public var LEFT(get, never):Bool;

  inline function get_LEFT() { return FlxG.keys.justPressed.LEFT; }
  public var RIGHT(get, never):Bool;

  inline function get_RIGHT() { return FlxG.keys.justPressed.RIGHT; }
  public var UP(get, never):Bool;

  inline function get_UP() { return FlxG.keys.justPressed.UP; }
  public var DOWN(get, never):Bool;

  inline function get_DOWN() { return FlxG.keys.justPressed.DOWN; }
  public var A(get, never):Bool;

  inline function get_A() { return Key.checkA(FlxG.keys.justPressed); }
  public var B(get, never):Bool;

  inline function get_B() { return Key.checkB(FlxG.keys.justPressed); }
  public var X(get, never):Bool;

  inline function get_X() { return Key.checkX(FlxG.keys.justPressed); }
}

/**
 * キー入力管理
 **/
class Key {
  public static var on:KeyOn = new KeyOn();
  public static var press:KeyPress = new KeyPress();

  public static function checkA(k:FlxKeyList):Bool {
    if(k.check(FlxKey.SPACE)) {
      return true;
    }
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
    if(k.check(FlxKey.CONTROL)) {
      return true;
    }
    if(k.check(FlxKey.C)) {
      return true;
    }
    return false;
  }
}
