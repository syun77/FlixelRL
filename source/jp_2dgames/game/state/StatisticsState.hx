package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.lib.Snd;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.save.PlayData;
import jp_2dgames.game.save.GameData;
import flixel.text.FlxText;
import jp_2dgames.game.util.BgWrap;
import flixel.FlxG;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = function() Snd.playSe("pi", true);
    leaveCallback = OnLeave;
  }
}

/**
 * プレイデータ閲覧画面
 **/
class StatisticsState extends FlxState {

  // 座標
  private static inline var TEXT_X = 128;
  private static inline var TEXT_X2 = 480;
  private static inline var TEXT_Y = 64;
  private static inline var TEXT_DY = 32;

  private var _txtList:List<FlxText>;
  private var _csv:CsvLoader;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap(false));

    // CSV読み込み
    _csv = new CsvLoader("assets/data/statistics.csv");

    // 情報テキスト
    _txtList = new List<FlxText>();
    var dat:PlayData = GameData.getPlayData();

    var px = TEXT_X;
    var py = TEXT_Y;

    // トータル
    var playtime = TextUtil.secToHHMMSS(Std.int(dat.playtime));
    createFlxText(px, py, playtime);
    py += TEXT_DY;
    createFlxText(px, py, dat.cntPlay);
    py += TEXT_DY;
    createFlxText(px, py, dat.cntGameclear);
    py += TEXT_DY;
    createFlxText(px, py, dat.cntEnemyKill);
    py += TEXT_DY;
    createFlxText(px, py, dat.cntNightmareKill);
    py += TEXT_DY;
    createFlxText(px, py, '${dat.totalMoney}G');
    py += TEXT_DY;

    // 最大
    px = TEXT_X2;
    py = TEXT_Y;
    createFlxText(px, py, GameData.getHiscore());
    py += TEXT_DY;
    createFlxText(px, py, dat.maxFloor);
    py += TEXT_DY;
    createFlxText(px, py, dat.maxLv);
    py += TEXT_DY;
    createFlxText(px, py, dat.maxMoney);
    py += TEXT_DY;
    createFlxText(px, py, dat.maxItem);
    py += TEXT_DY;

    var idx = 0;
    for(txt in _txtList) {
      var px = txt.x;
      txt.x = FlxG.width;
      FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.01});
      idx++;
    }

    // BACK
    var BACK_X = FlxG.width/2 - 100;
    var BACK_Y = FlxG.height - 64;
    this.add(new MyButton(BACK_X, BACK_Y, "BACK", function() {
      // Statsトップに戻る
      FlxG.switchState(new StatsState());
    }));
  }

  /**
   * テキスト作成
   **/
  private function createFlxText(px:Float, py:Float, info:Dynamic):FlxText {
    var txt = new FlxText(px, py, 640);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    var idx = _txtList.length + 1;
    var caption = _csv.getString(idx, "msg");
    txt.text = '${caption}: ${info}';
    _txtList.add(txt);
    this.add(txt);
    return txt;
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
    super.update();
  }
}
