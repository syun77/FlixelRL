package jp_2dgames.game.state;
import jp_2dgames.game.save.GameData;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxState;

/**
 * 敵ログ画面
 **/
class EnemyLogState extends FlxState {

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
      var bLog = csv.searchItemInt("id", '${enemyID}', "log", false);
      return bLog == 1;
    });
    // ソート
    enemyList.sort(function(a, b) {
      var aSort = csv.searchItemInt("id", '${a}', "sortkey", false);
      var bSort = csv.searchItemInt("id", '${b}', "sortkey", false);
      return aSort - bSort;
    });

    trace(enemyList);


    var enemyLogs = GameData.getPlayData().flgEnemyKill;
  }

  private function _addEnemy(csv:CsvLoader, id:Int, cnt:Int):Void {

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

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
