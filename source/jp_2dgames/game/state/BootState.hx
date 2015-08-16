package jp_2dgames.game.state;
import jp_2dgames.game.save.GameData;
import jp_2dgames.game.playlog.PlayLog;
import jp_2dgames.game.util.CauseOfDeathMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * ゲーム起動時に一度だけ呼び出されるクラス
 **/
class BootState extends FlxState {
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // セーブデータのロード
    GameData.init();
    GameData.load();

    // プレイログのロード
    PlayLog.load();

    // 死亡理由メッセージ読み込み
    CauseOfDeathMgr.create();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
  #if flash
    FlxG.switchState(new TitleState());
  #else
//    FlxG.switchState(new PlayInitState());
//    FlxG.switchState(new TitleState());
//    FlxG.switchState(new StatsState());
//    FlxG.switchState(new StatisticsState());
    FlxG.switchState(new PlayLogState());
  #end

    super.update();
  }
}
