package jp_2dgames.game.actor;
import flixel.FlxSprite;

/**
 * バッドステータスのアイコン表示
 **/
class ActorBalloon extends FlxSprite {
  public function new() {
    super();

    loadGraphic("assets/images/balloon.png", true);

    // 消しておく
    kill();
  }

  public function show()
}
