package jp_2dgames.game;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Npc;
import jp_2dgames.game.util.DirUtil;
import flixel.util.FlxPoint;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.gui.GuiBuyDetail;
import jp_2dgames.game.item.ItemData;
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

  /**
   * アイテムの拡張パラメータを取得する
   **/
  public static function generateItemParam(itemid:Int) {

    var param = new ItemExtraParam();

    switch(ItemUtil.getType(itemid)) {
      case IType.Weapon, IType.Armor:
        // 使用回数
        var extra  = ItemUtil.getExtra(itemid);
        var extval = ItemUtil.getExtVal(itemid);
        if(extra == "drill") {

          param.condition = FlxRandom.intRanged(5, 15);
        }

        // 付加威力値
        var func = function() {
          var rnd = FlxRandom.intRanged(0, 999);
          if(rnd < 550) { return 0; } // 55%
          else if(rnd < 800) { return 1; } // 25%
          else if(rnd < 920) { return 2; } // 12%
          else if(rnd < 955) { return 3; } // 3.5%
          else if(rnd < 990) { return -1;} // 3.5%
          else if(rnd < 998) { return 4; } // 0.8%
          else { return 5;} // 0.2%
        }
        param.value = func();
      case IType.Wand:
        // 使用回数
        param.value = FlxRandom.intRanged(3, 6);
      default:
    }

    return param;
  }
}

/**
 * アイテムや敵を生成するクラス
 **/
class Generator {
  public function new() {
  }

  /**
   * 出現した敵を眠り状態にするかどうか
   **/
  public static function checkEnemySleep(enemy:Enemy):Bool {
    // 遠くに出現した敵ほど眠りやすくなる
    var player = cast(FlxG.state, PlayState).player;
    var dx = player.xchip - enemy.xchip;
    var dy = player.ychip - enemy.ychip;
    var ratio:Int = 100;
    ratio -= (dx*10) + (dy*10);
    return FlxRandom.chanceRoll(ratio);
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
          // 出現演出を抑制
          Enemy.bEffectStart = false;
          var eid = gEnemy.generate();
          if(eid > 0) {
            var e:Enemy = Enemy.parent.recycle();
            var params = new Params();
            params.id = eid;
            e.init(i, j, DirUtil.random(), params, true);
            if(checkEnemySleep(e)) {
              // 眠り状態にする
              e.changeBadStatus(BadStatus.Sleep, true);
            }
          }
          // 出現演出を有効化
          Enemy.bEffectStart = true;

        case Field.ITEM:
          // アイテムを生成
          var itemid = gItem.generate();
          if(itemid == 0) {
            trace("Warning: Invalid item_appear.csv");
            itemid = 1;
          }
          var param = GenerateInfo.generateItemParam(itemid);
          if(FlxRandom.chanceRoll(2)) {
            // 2%でお金出現
            var max = 100 + Global.getFloor() * 20;
            if(max > 500) {
              max = 500;
            }
            var v = FlxRandom.intRanged(100, max);
            DropItem.addMoney(i, j, v);
          }
          else {
            // アイテム
            DropItem.add(i, j, itemid, param);
          }

        case Field.SHOP:
          // ショップが存在するのでショップの販売品を設定する
          for(i in 0...GuiBuyDetail.ITEM_MAX) {
            var itemid = gItem.generate();
            if(itemid == 0) {
              trace("Warning: Invalid item_appear.csv");
              itemid = 1;
            }
            var param = GenerateInfo.generateItemParam(itemid);
            var item = new ItemData(itemid, param);
            GuiBuyDetail.addItem(item);
          }

        case Field.CAT:
          // ネコ
          var tbl = [Npc.TYPE_RED, Npc.TYPE_BLUE, Npc.TYPE_WHITE, Npc.TYPE_GREEN];
          FlxRandom.shuffleArray(tbl, 3);
          var type = Npc.TYPE_RED;
          for(t in tbl) {
            var itemid = Npc.typeToItemID(t);
            if(Global.hasItem(itemid) == false) {
              // 持っていないオーブ
              type = t;
              break;
            }
          }
          // 生成
          Npc.add(type, i, j);
      }
    });
  }

  /**
   * 敵を出現させる
   * @param csv Csv管理
   * @param layer フィールドLayer
   **/
  public static function checkRandomEnemy(csv:Csv, layer:Layer2D):Void {

    if(Global.isMapExtra()) {
      // 特殊ステージでは敵は出現しない
      return;
    }

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
        if(player.existsPosition(px, py)) {
          // 生成できないのでやり直す
          continue;
        }
        if(Enemy.getFromPosition(px, py) != null) {
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
