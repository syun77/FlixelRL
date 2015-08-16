package jp_2dgames.game.playlog;

/**
 * プレイログデータ
 **/
class PlayLogData {
  public var user:String;
  public var score:Int;
  public var lv:Int;
  public var floor:Int;
  public var death:String;
  public var playtime:Int;
  public var date:String;
  public function new() {
  }
  public function copyFromDynamic(data:Dynamic):Void {
    user     = data.user;
    score    = data.score;
    lv       = data.lv;
    floor    = data.floor;
    death    = data.death;
    playtime = data.playtime;
    date     = data.date;
  }
}
