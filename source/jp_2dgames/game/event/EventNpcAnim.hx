package jp_2dgames.game.event;
import flixel.animation.FlxAnimationController;
import jp_2dgames.game.util.DirUtil;

/**
 * イベントNPCのアニメーション定義
 **/
class EventNpcAnim {

  /**
   * リソースファイル名を取得する
   **/
  public static function getResource(type:String):String {
    switch(type) {
      case "player": return "assets/images/player.png";
      case "cat":    return "assets/images/cat.png";
      default:
        throw 'Error: Invalid type. ${type}';
    }
  }

  /**
   * 登録するアニメーションを定義
   * @param animation アニメーションオブジェクト
   * @param type 種別
   **/
  public static function registAnim(animation:FlxAnimationController, type:String):Void {
    switch(type) {
      case "player":
        // アニメーションを登録
        // 待機アニメ
        // アニメーション速度
        var speed = 2;
        animation.add(getAnimName(type, true, Dir.Left), [0, 1], speed);
        animation.add(getAnimName(type, true, Dir.Up), [4, 5], speed);
        animation.add(getAnimName(type, true, Dir.Right), [8, 9], speed);
        animation.add(getAnimName(type, true, Dir.Down), [12, 13], speed);

        // 歩きアニメ
        speed = 6;
        animation.add(getAnimName(type, false, Dir.Left), [2, 3], speed);
        animation.add(getAnimName(type, false, Dir.Up), [6, 7], speed);
        animation.add(getAnimName(type, false, Dir.Right), [10, 11], speed);
        animation.add(getAnimName(type, false, Dir.Down), [14, 15], speed);
      default:
        // アニメーションを登録
        var speed = 6;
        animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // 左
        animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // 上
        animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // 右
        animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // 下
    }
  }

  /**
   * アニメーション名を取得する
   * @param type  種別
   * @param bStop 停止状態かどうか
   * @param dir   方向
   * @return アニメーション名
   **/
  public static function getAnimName(type:String, bStop:Bool, dir:Dir):String {

    switch(type) {
      case "player":
        var pre = bStop ? "stop" : "walk";
        var suf = DirUtil.toString(dir);

        return pre + "-" + suf;

      default:
        return DirUtil.toString(dir);
    }
  }
}
