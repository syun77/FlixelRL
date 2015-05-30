package jp_2dgames.game.item;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import jp_2dgames.game.actor.Enemy;
import flixel.util.FlxPoint;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.actor.Actor;

/**
 * 投げたアイテムの情報
 **/
class ThrowItem {
  // 終了チェック
  private var _bEnd:Bool;
  public function isEnd():Bool {
    return _bEnd;
  }
  private var _spr:DropItem;

  public function new() {
  }

  /**
   * 終了処理
   **/
  private function _end():Void {
    FlxG.state.remove(_spr);
    _bEnd = true;
  }

  /**
   * 情報を設定する
   **/
  public function start(actor:Actor, item:ItemData):Void {
    _bEnd = false;

    var itemname = ItemUtil.getName(item);
    Message.push2(Msg.ITEM_THROW, [actor.name, itemname]);

    {
      var xstart = actor.xchip;
      var ystart = actor.ychip;
      _spr = new DropItem();
      var type = ItemUtil.getType(item.id);
      _spr.init(xstart, ystart, type, item.id, item.param);
      _spr.revive();
      FlxG.state.add(_spr);
    }

    var distance:Float = 0.3;
    var pt = FlxPoint.get(actor.xchip, actor.ychip);
    var moveItem = function() {
      // 敵や壁に当たるまで進む
      while(true) {
        distance += 0.01;
        var xprev = Std.int(pt.x);
        var yprev = Std.int(pt.y);
        DirUtil.move(actor.dir, pt);
        var xpos = Std.int(pt.x);
        var ypos = Std.int(pt.y);
        if(Field.isCollision(xpos, ypos)) {
          // 壁に当たった
          var xtarget = Field.toWorldX(xprev);
          var ytarget = Field.toWorldY(yprev);
          FlxTween.tween(_spr, {x:xtarget, y:ytarget}, distance, {ease:FlxEase.bounceOut, complete:function(tween:FlxTween) {
            Message.push2(Msg.ITEM_HIT_WALL, [itemname]);

            if(DropItem.checkDrop(pt, xprev, yprev)) {
              // 床に置ける
              DropItem.add(Std.int(pt.x), Std.int(pt.y), item.id, item.param);
            }
            else {
              // 床に置けないので壊れる
              Message.push2(Msg.ITEM_DESTORY, [itemname]);
            }

            // おしまい
            _end();
          }});
          break;
        }
        var e:Enemy = Enemy.getFromPositino(xpos, ypos);
        if(e != null) {
          // 敵に当たった
          var xtarget = Field.toWorldX(xpos);
          var ytarget = Field.toWorldY(ypos);
          FlxTween.tween(_spr, {x:xtarget, y:ytarget}, distance, {ease:FlxEase.backIn, complete:function(tween:FlxTween) {
            if(e.hitItem(actor, item) == false) {
              // 敵がかわした
              Message.push2(Msg.MISS, [e.name]);
              pt.set(xpos, ypos);
              if(DropItem.checkDrop(pt, xpos, ypos)) {
                // 床に置ける
                DropItem.add(Std.int(pt.x), Std.int(pt.y), item.id, item.param);
              }
              else {
                // 床に置けないので壊れる
                Message.push2(Msg.ITEM_DESTORY, [itemname]);
              }
            }

            // おしまい
            _end();
          }});
          break;
        }
      }
    }
    moveItem();

    pt.put();
  }
}
