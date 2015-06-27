package jp_2dgames.game;

import flixel.FlxG;
import jp_2dgames.lib.Layer2D;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Enemy;
import flixel.util.FlxRandom;
import jp_2dgames.lib.Layer2D;

/**
 * 生成情報
 **/
class GenerateInfo {
  public static inline var TYPE_ENEMY:Int = 0;
  public static inline var TYPE_ITEM:Int = 1;

  private var _idxs:Array<Int>;   // 出現するIDの配列
  private var _ratios:Array<Int>; // 出現確率の配列
  private var _sum:Int;           // 確率の合計

  /**
   * コンストラクタ
   **/
  public function new(csv:Csv, type:Int) {
    // 変数初期化
    _idxs   = new Array<Int>();
    _ratios = new Array<Int>();
    _sum    = 0;

    switch(type) {
      case TYPE_ENEMY:
        // 敵の情報
        var id = csv.getEnemyAppearId(Global.getFloor());
        for(i in 0...5) {
          var eid = csv.enemy_appear.getInt(id, 'e${i}');
          if(eid <= 0) {
            // 未設定
            continue;
          }
          var ratio = csv.enemy_appear.getInt(id, 'e${i}_r');
          if(ratio <= 0) {
            // 未設定
            continue;
          }
          _idxs.push(eid);
          _ratios.push(ratio);
          _sum += ratio;
        }

      case TYPE_ITEM:
        // アイテムの情報
        var floor = Global.getFloor();
        csv.item_appear.foreach(function(v:Map<String,String>) {
          var start = Std.parseInt(v.get("start"));
          var end = Std.parseInt(v.get("end"));
          var id = Std.parseInt(v.get("itemid"));
          var ratio = Std.parseInt(v.get("ratio"));
          if(start <= floor && floor <= end) {
            _idxs.push(id);
            _ratios.push(ratio);
            _sum += ratio;
          }
        });
    }
  }

  /**
   * ランダムにIDを決定する
   **/
  public function generate():Int {
    // ランダムで決定する
    var rnd = FlxRandom.intRanged(0, _sum-1);
    var idx:Int = 0;
    for(ratio in _ratios) {
      if(rnd < ratio) {
        // マッチした
        return _idxs[idx];
      }
      rnd -= ratio;
      idx++;
    }

    // 見つからなかった
    return 0;
  }
}

/**
 * アイテムや敵を生成するクラス
 **/
class Generator {
  public function new() {
  }

  /**
   * フィールド情報からアイテムや敵を自動配置
   **/
  public static function exec(csv:Csv, layer:Layer2D):Void {
    var gEnemy = new GenerateInfo(csv, GenerateInfo.TYPE_ENEMY);
    var gItem = new GenerateInfo(csv, GenerateInfo.TYPE_ITEM);

    // 各種オブジェクトを配置
    layer.forEach(function(i, j, v) {
      switch(v) {
        case Field.ENEMY:
          // 敵を生成
          var eid = gEnemy.generate();
          if(eid > 0) {
            var e:Enemy = Enemy.parent.recycle();
            var params = new Params();
            params.id = eid;
            e.init(i, j, DirUtil.random(), params, true);
          }
        case Field.ITEM:
          // アイテムを生成
          var itemid = gItem.generate();
          if(itemid == 0) {
            trace("Warning: Invalid item_appear.csv");
            itemid = 1;
          }
          var param = new ItemExtraParam();
          switch(ItemUtil.getType(itemid)) {
            case IType.Weapon, IType.Armor:
              // 使用回数
              param.condition = FlxRandom.intRanged(5, 15);
              // 付加威力値
              var func = function() {
                var rnd = FlxRandom.intRanged(0, 99);
                if(rnd < 35) { return 0; } // 35%
                else if(rnd < 55) { return 1; } // 20%
                else if(rnd < 70) { return 2; } // 15%
                else if(rnd < 80) { return 3; } // 10%
                else if(rnd < 90) { return -1;} // 10%
                else if(rnd < 96) { return 4; } // 6%
                else { return 5;} // 4%
              }
              param.value = func();
            case IType.Wand:
              // 使用回数
              param.value = FlxRandom.intRanged(3, 6);
            default:
          }
          DropItem.add(i, j, itemid, param);
        //          DropItem.addMoney(i, j, 100);
      }
    });
  }

  /**
   * 敵を出現させる
   * @param csv Csv管理
   * @param layer フィールドLayer
   **/
  public static function checkRandomEnemy(csv:Csv, layer:Layer2D):Void {
    var id = csv.getEnemyAppearId(Global.getFloor());
    var turn = csv.enemy_appear.getInt(id, "turn");
    if(turn == 0) {
      // 敵は出現しない
      return;
    }
    if(Global.getTurn()%turn != 0) {
      // 出現しないターン
      return;
    }
    var cnt = csv.enemy_appear.getInt(id, "max");
    cnt -= Enemy.parent.countLiving();
    if(cnt < 1) {
      // 敵の出現最大数を超えている
      return;
    }

    var info = new GenerateInfo(csv, GenerateInfo.TYPE_ENEMY);
    var player = cast(FlxG.state, PlayState).player;

    for(i in 0...cnt) {

      // チャレンジ回数
      var retryCount = 10;
      for(j in 0...retryCount) {

        var pt = layer.searchRandom(Field.ENEMY);
        if(pt == null) {
          // 出現ポイントが存在しない
          break;
        }
        var px = Std.int(pt.x);
        var py = Std.int(pt.y);
        pt.put();
        if(player.checkPosition(px, py)) {
          // 生成できないのでやり直す
          continue;
        }
        if(Enemy.getFromPositino(px, py) != null) {
          // 生成できないのでやり直す
          continue;
        }

        // 生成できる
        var eid = info.generate();
        Enemy.add(eid, px, py);
        break;
      }
    }
  }
}
