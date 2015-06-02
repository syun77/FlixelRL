package jp_2dgames.game;

import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Enemy;
import flixel.util.FlxRandom;
import jp_2dgames.lib.Layer2D;

/**
 * アイテムや敵を生成するクラス
 **/
class Generator {
  public function new() {
  }

  /**
   * アイテムや敵を自動配置
   **/
  public static function exec(csv:Csv, layer:Layer2D):Void {
    // 敵出現情報を計算
    var eIds = [];
    var eRatios = [];
    var sum:Int = 0;
    {
      var id = csv.getEnemyAppearId(Global.getFloor());
      for(i in 0...5) {
        var eid = csv.enemy_appear.getInt(id, 'e${i}');
        if(eid <= 0) {
          continue;
        }
        var ratio = csv.enemy_appear.getInt(id, 'e${i}_r');
        if(ratio <= 0) {
          continue;
        }
        eIds.push(eid);
        eRatios.push(ratio);
        sum += ratio;
      }
    }
    // アイテム出現情報を計算
    var itemIds = [];
    var itemRatios = [];
    var itemSum:Int = 0;
    {
      var floor = Global.getFloor();
      csv.item_appear.foreach(function(v:Map<String,String>) {
        var start = Std.parseInt(v.get("start"));
        var end = Std.parseInt(v.get("end"));
        var id = Std.parseInt(v.get("itemid"));
        var ratio = Std.parseInt(v.get("ratio"));
        if(start <= floor && floor <= end) {
          itemIds.push(id);
          itemRatios.push(ratio);
          itemSum += ratio;
        }
      });
    }

    // 各種オブジェクトを配置
    layer.forEach(function(i, j, v) {
      switch(v) {
        case Field.ENEMY:
          // 敵を生成
          var func = function() {
            // 敵IDをランダムで決定する
            var rnd = FlxRandom.intRanged(0, sum-1);
            var idx:Int = 0;
            for(ratio in eRatios) {
              if(rnd < ratio) {
                return eIds[idx];
              }
              rnd -= ratio;
              idx++;
            }
            return 0;
          };
          // 敵ID取得
          var eid = func();
          if(eid > 0) {
            var e:Enemy = Enemy.parent.recycle();
            var params = new Params();
            params.id = eid;
            e.init(i, j, DirUtil.random(), params, true);
          }
        case Field.ITEM:
          // アイテムを生成
          var func = function() {
            // アイテムをランダムで決定する
            var rnd = FlxRandom.intRanged(0, itemSum-1);
            var idx:Int = 0;
            for(ratio in itemRatios) {
              if(rnd < ratio) {
                return itemIds[idx];
              }
              rnd -= ratio;
              idx++;
            }
            return 0;
          }
          // アイテムIDを取得する
          var itemid = func();
          if(itemid == 0) {
            trace("Warning: Invalid item_appear.csv");
            itemid = 1;
          }
          var param = new ItemExtraParam();
          switch(ItemUtil.getType(itemid)) {
            case IType.Weapon, IType.Armor:
              param.condition = FlxRandom.intRanged(5, 15);
            default:
          }
          DropItem.add(i, j, itemid, param);
        //          DropItem.addMoney(i, j, 100);
      }
    });
  }
}
