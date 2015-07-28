package jp_2dgames.game.util;

import flixel.util.FlxRandom;
import openfl.Assets;

/**
 * 名前自動生成
 **/
class NameGenerator {
  private var _males:Array<String>;
  private var _females:Array<String>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _males = Assets.getText("assets/data/name/male.cpp").split("\n");
    _females = Assets.getText("assets/data/name/female.cpp").split("\n");
  }

  public function get():String {
    if(FlxRandom.chanceRoll()) {
      return getMale();
    }
    else {
      return getFemale();
    }
  }

  public function getMale():String {
    var rnd = FlxRandom.intRanged(0, _males.length-1);
    return _males[rnd];
  }

  public function getFemale():String {
    var rnd = FlxRandom.intRanged(0, _females.length-1);
    return _females[rnd];
  }
}
