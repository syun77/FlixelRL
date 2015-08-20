package jp_2dgames.game.state;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxSprite;
import flixel.text.FlxText;
import jp_2dgames.game.save.GameData;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxState;

/**
 * 敵ログ画面
 **/
class EnemyLogState extends FlxState {

  // 座標
  private static inline var POS_X = 32;
  private static inline var POS_Y = 32;
  private static inline var POS_DX = 128;
  private static inline var POS_DY = 72;

  // カーソル
  private var _cursor:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var csv = new CsvLoader("assets/levels/enemy.csv");
    // ログ表示するID
    // ID配列の作成
    var enemyList = new Array<Int>();
    for(i in 1...csv.size()-1) {
      enemyList.push(Std.parseInt(csv.searchItem("id", '${i}', "id")));
    }
    // ログ表示するIDを抽出
    enemyList = enemyList.filter(function(enemyID:Int) {
      var bLog = _getParamInt(csv, enemyID, "log");
      return bLog == 1;
    });
    // ソート
    enemyList.sort(function(a, b) {
      var aSort = _getParamInt(csv, a, "sortkey");
      var bSort = _getParamInt(csv, b, "sortkey");
      return aSort - bSort;
    });

    var enemyLogs = GameData.getPlayData().flgEnemyKill;
    var idx = 0;
    for(enemyID in enemyList) {
      var bUnlock = (enemyLogs.indexOf(enemyID) == -1);
      _addEnemy(csv, enemyID, idx, bUnlock);
      idx++;
    }

    // カーソル
    _cursor = new FlxSprite();
    _cursor.loadGraphic("assets/images/ui/enemylog_cursor.png");
    this.add(_cursor);
  }

  private function _getParamInt(csv:CsvLoader, id:Int, name:String):Int {
    return csv.searchItemInt("id", '${id}', name, false);
  }
  private function _getParam(csv:CsvLoader, id:Int, name:String):String {
    return csv.searchItem("id", '${id}', name, false);
  }

  private function _addEnemy(csv:CsvLoader, id:Int, cnt:Int, bUnlock:Bool):Void {
    var name = _getParam(csv, id, "name");
    var detail = _getParam(csv, id, "detail");

    var px = POS_X + POS_DX * (cnt%6);
    var py = POS_Y + POS_DY * Std.int(cnt/6);

    var txtName = new FlxText(px, py, POS_DX);
    txtName.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    txtName.text = name;
    var txtDetail = new FlxText(px, py+24, POS_DX, detail);
    txtDetail.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    txtDetail.text = detail;
    this.add(txtName);
//    this.add(txtDetail);
    var spr = new FlxSprite(px, py+20);
    _registAnim(spr, csv, id);
    this.add(spr);
  }

  private function _registAnim(sprEnemy:FlxSprite, csv:CsvLoader, id:Int):Void {

    var name = _getParam(csv, id, "image");
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
   * 更新
   **/
  override public function update():Void {
    super.update();

    // カーソル更新
    {
      var px = POS_X;
      var py = POS_Y;
      px += Std.int((FlxG.mouse.x - POS_X) / POS_DX) * POS_DX;
      py += Std.int((FlxG.mouse.y - POS_Y) / POS_DY) * POS_DY;
      _cursor.x = px;
      _cursor.y = py;
    }

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
