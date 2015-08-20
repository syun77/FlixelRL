package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxButtonPlus;
import jp_2dgames.game.util.BgWrap;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxSprite;
import flixel.text.FlxText;
import jp_2dgames.game.save.GameData;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = OnEnter;
    leaveCallback = OnLeave;
  }
}

/**
 * 敵ログ画面
 **/
class EnemyLogState extends FlxState {

  // 座標
  private static inline var POS_X = 48;
  private static inline var POS_Y = 16;
  private static inline var POS_DX = 128;
  private static inline var POS_DY = 72;

  // 情報
  private static inline var INFO_X = 320;
  private static inline var INFO_Y = 384;

  // カーソル用の座標オフセット
  private static inline var CURSOR_OFS_X = -8;
  private static inline var CURSOR_OFS_Y = -8;

  // 戻るボタン
  private static inline var BACK_X = 600;
  private static inline var BACK_Y = 416;

  // 表示する列と行の最大
  private static inline var MAX_COL:Int = 6;
  private static inline var MAX_ROW:Int = 6;

  private var _csv:CsvLoader;

  // カーソル
  private var _cursor:FlxSprite;

  // 敵IDリスト
  private var _enemyList:Array<Int>;

  // 情報
  private var _txtInfo:FlxText;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap(false));

    _csv = new CsvLoader("assets/levels/enemy.csv");
    // ログ表示するID
    // ID配列の作成
    _enemyList = new Array<Int>();
    for(i in 1..._csv.size()-1) {
      _enemyList.push(Std.parseInt(_csv.searchItem("id", '${i}', "id")));
    }
    // ログ表示するIDを抽出
    _enemyList = _enemyList.filter(function(enemyID:Int) {
      var bLog = _getParamInt(enemyID, "log");
      return bLog == 1;
    });
    // ソート
    _enemyList.sort(function(a, b) {
      var aSort = _getParamInt(a, "sortkey");
      var bSort = _getParamInt(b, "sortkey");
      return aSort - bSort;
    });

    var enemyLogs = GameData.getPlayData().flgEnemyKill;
    var idx = 0;
    for(enemyID in _enemyList) {
      var bUnlock = (enemyLogs.indexOf(enemyID) != -1);
      _addEnemy(enemyID, idx, bUnlock);
      idx++;
    }

    // 情報
    _txtInfo = new FlxText(INFO_X, INFO_Y, 600);
    _txtInfo.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtInfo);

    // カーソル
    _cursor = new FlxSprite();
    _cursor.loadGraphic("assets/images/ui/enemylog_cursor.png");
    this.add(_cursor);

    // 戻るボタン
    var btnBack = new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new StatsState());
    });
    this.add(btnBack);
  }

  private function _getParamInt(id:Int, name:String):Int {
    return _csv.searchItemInt("id", '${id}', name, false);
  }
  private function _getParam(id:Int, name:String):String {
    return _csv.searchItem("id", '${id}', name, false);
  }

  /**
   * 敵の表示
   **/
  private function _addEnemy(id:Int, cnt:Int, bUnlock:Bool):Void {
    var name = _getParam(id, "name");
    if(bUnlock == false) {
      name = "???";
    }

    var px = POS_X + POS_DX * (cnt%MAX_COL);
    var py = POS_Y + POS_DY * Std.int(cnt/MAX_ROW);

    var txtName = new FlxText(px, py, POS_DX);
    txtName.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    txtName.text = name;
    this.add(txtName);
    var spr = new FlxSprite(px, py+20);
    _registAnim(spr, id);
    if(bUnlock == false) {
      spr.color = FlxColor.BLACK;
    }
    spr.scale.set(0, 0);
    FlxTween.tween(spr.scale, {x:1, y:1}, 2, {ease:FlxEase.elasticOut, startDelay:cnt*0.01});
    this.add(spr);
  }

  private function _registAnim(sprEnemy:FlxSprite, id:Int):Void {

    var name = _getParam(id, "image");
    sprEnemy.loadGraphic('assets/images/monster/${name}.png', true);

    // アニメーションを登録
    var speed = 6;
    sprEnemy.animation.add("play",  [9, 10, 11, 10], speed); // 下
    sprEnemy.animation.play("play");
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * マウス座標から選択している敵を取得する
   **/
  private function _getSelectedEnemyID():Int {
    var xIdx = Std.int((FlxG.mouse.x - POS_X) / POS_DX);
    var yIdx = Std.int((FlxG.mouse.y - POS_Y) / POS_DY);
    if(xIdx > MAX_COL-1) { xIdx = MAX_COL-1; }
    if(yIdx > MAX_ROW-1) { yIdx = MAX_ROW-1; }

    var idx = (yIdx * MAX_COL) + xIdx;
    if(idx >= _enemyList.length) {
      // 選択していない
      return -1;
    }

    var enemyID = _enemyList[idx];
    var enemyLogs = GameData.getPlayData().flgEnemyKill;
    if(enemyLogs.indexOf(enemyID) == -1) {
      // 倒していない敵
      return -2;
    }

    // 倒した敵
    return enemyID;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // カーソル座標更新
    {
      var px = POS_X;
      var py = POS_Y;
      var xIdx = Std.int((FlxG.mouse.x - POS_X) / POS_DX);
      var yIdx = Std.int((FlxG.mouse.y - POS_Y) / POS_DY);
      if(xIdx > MAX_COL-1) { xIdx = MAX_COL-1; }
      if(yIdx > MAX_ROW-1) { yIdx = MAX_ROW-1; }
      px += xIdx * POS_DX;
      py += yIdx * POS_DY;
      _cursor.x = px + CURSOR_OFS_X;
      _cursor.y = py + CURSOR_OFS_Y;
    }

    // 敵情報更新
    {
      var enemyID = _getSelectedEnemyID();
      if(enemyID == -1) {
        // 何も選択していない
        _cursor.visible = false;
        _txtInfo.text = "";
      }
      else {
        _cursor.visible = true;
        if(enemyID == -2) {
          // 倒していない敵
          _txtInfo.text = "???";
        }
        else {
          _txtInfo.text = _getParam(enemyID, "detail");
        }
      }
    }

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
