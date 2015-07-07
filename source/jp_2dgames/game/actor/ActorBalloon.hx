package jp_2dgames.game.actor;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.FlxSprite;

/**
 * バッドステータスのアイコン表示
 **/
class ActorBalloon extends FlxSprite {
  public function new() {
    super();

    loadGraphic("assets/images/balloon.png", true);

    // アニメ登録
    animation.add(BadStatusUtil.toString(BadStatus.Confusion), [0], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Sleep),     [1], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Paralysis), [2], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Sickness),  [3], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Powerful),  [4], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Anger),     [5], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Poison),    [6], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Star),      [7], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Closed),    [8], 1);

    // 消しておく
    kill();
  }

  /**
   * アイコン表示
   **/
  public function show(stt:BadStatus) {

    if(stt == BadStatus.None) {
      // バッドステータスなしの場合は非表示
      kill();
      return;
    }
    revive();

    // アイコン変更
    var str = BadStatusUtil.toString(stt);
    animation.play(str);
  }

  override function kill():Void {
    // 画面外に出しておく
    x = -100000;
    super.kill();
  }
}
