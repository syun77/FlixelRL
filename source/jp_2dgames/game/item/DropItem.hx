package jp_2dgames.game.item;
import jp_2dgames.game.save.GameData;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleKira;
import jp_2dgames.game.util.DirUtil;
import flixel.FlxG;
import flixel.util.FlxRandom;
import jp_2dgames.game.util.DirUtil.Dir;
import flixel.util.FlxPoint;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.item.ItemUtil.IType;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * アイテム
 **/
class DropItem extends FlxSprite {

  // 管理クラス
  public static var parent:FlxTypedGroup<DropItem> = null;
  // チップ座標
  public var xchip(default, null):Int;
  public var ychip(default, null):Int;
  // ID
  public var id(default, null):Int;
  // アイテム種別
  public var type(default, null):IType;
  // 名前
  public var name(default, null):String;
  // 拡張パラメータ
  public var param:ItemExtraParam;

  /**
   * アイテムを配置する
   **/
  public static function add(i:Int, j:Int, itemid:Int, param:ItemExtraParam):DropItem {
    var item:DropItem = parent.recycle();
    if(item == null) {
      return null;
    }
    var type = ItemUtil.getType(itemid);
    item.init(i, j, type, itemid, param);

    return item;
  }

  /**
   * お金を配置する
   **/
  public static function addMoney(i:Int, j:Int, value:Int):DropItem {
    var item:DropItem = parent.recycle();
    if(item == null) {
      return null;
    }
    var param = new ItemExtraParam();
    param.value = value;
    item.init(i, j, IType.Money, ItemConst.MONEY, param);
    return item;
  }

  /**
   * 指定の座標にあるアイテム情報を取得する
   * @return 何もなかったらnull
   **/
  public static function getFromPosition(xchip:Int, ychip:Int):ItemData {
    var data:ItemData = null;
    parent.forEachAlive(function(item:DropItem) {
      if(xchip == item.xchip && ychip == item.ychip) {
        data = new ItemData(item.id, item.param);
      }
    });

    return data;
  }

  /**
   * 指定座標にあるアイテムを破壊する
   **/
  public static function killFromPosition(xchip:Int, ychip:Int):Bool {
    var ret = false;
    parent.forEachAlive(function(item:DropItem) {
      if(xchip == item.xchip && ychip == item.ychip) {
        item.kill();
        ret = true;
      }
    });

    return true;
  }

  /**
   * 指定の位置にアイテムを落とせるかどうかチェックする
   * @param outPt 落とせる場合の座標
   * @param xchip チェックする座標(X)
   * @param ychip チェックする座標(Y)
   * @return 落とせる場合はtrue
   **/
  public static function checkDrop(outPt:FlxPoint, xchip:Int, ychip:Int):Bool {
    // 上下左右4方向のみを調べる
    var dirs = [Dir.Left, Dir.Up, Dir.Right, Dir.Down];
    FlxRandom.shuffleArray(dirs, 1);
    // 最初は開始地点を調べる
    dirs.insert(0, Dir.None);
    for(dir in dirs) {
      outPt.set(xchip, ychip);
      // 指定の方向に動かしてみる
      outPt = DirUtil.move(dir, outPt);
      var xpos = Std.int(outPt.x);
      var ypos = Std.int(outPt.y);
      // 配置できるかチェック
      var bPut = true;
      parent.forEachAlive(function(drop:DropItem) {
        if(Field.isCollision(xpos, ypos)) {
          // 配置できない
          bPut = false;
        }
        if(drop.xchip == xpos && drop.ychip == ypos) {
          // 配置できない
          bPut = false;
        }
      });

      if(bPut) {
        // 配置できる
        return true;
      }
    }

    // 配置できない
    return false;
  }

  /**
   * 指定座標にあるアイテムを拾う
   * @return アイテムを拾えたらtrue
   **/
  public static function pickup(xchip:Int, ychip:Int):Bool {
    var bFind = false;
    parent.forEachAlive(function(item:DropItem) {
      if(xchip == item.xchip && ychip == item.ychip) {
        // 拾える
        bFind = true;
        if(item.type == IType.Money) {
          // お金はインベントリに入れない
          Message.push2(Msg.ITEM_PICKUP, [item.name]);
          Global.addMoney(item.param.value);
          item.kill();
          FlxG.sound.play("coin");
        }
        else {
          // アイテム所持数をチェック
          if(Inventory.isFull()) {
            // 拾えない
            Message.push2(Msg.ITEM_FULL);
            Message.push2(Msg.ITEM_STEPON, [item.name]);
          }
          else {
            // アイテムを拾えた
            Message.push2(Msg.ITEM_PICKUP, [item.name]);
            Inventory.push(item.id, item.param);
            item.kill();
            FlxG.sound.play("pickup");
          }
        }
      }
    });

    if(bFind) {
      // アイテムを拾った
      var px = Field.toWorldX(xchip);
      var py = Field.toWorldY(ychip);
      Particle.start(PType.Ring2, px, py, FlxColor.LIME);
      return true;
    }

    // 拾えなかった
    return false;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 拡張パラメータ
    param = new ItemExtraParam();

    // 画像読み込み
    loadGraphic("assets/images/item.png", true);

    // アニメーションを登録
    _registAnim();

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 消しておく
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Int, Y:Int, type:IType, itemid:Int, param:ItemExtraParam) {
    id = itemid;
    this.type = type;
    xchip = X;
    ychip = Y;
    x = Field.toWorldX(X);
    y = Field.toWorldY(Y);

    // 拡張パラメータをコピー
    ItemExtraParam.copy(this.param, param);

    var itemdata = new ItemData(itemid, param);
    // 名前
    if(type == IType.Money) {
      // お金は特殊
      name = '${param.value}G';
    }
    else {
      name = ItemUtil.getName(itemdata);
    }

    // アニメーション再生
    if(type == IType.Orb) {
      // オーブはそれぞれに画像の種類がある
      var name = ItemUtil.toString(type) + param.value;
      animation.play(name);
    }
    else {
      animation.play(ItemUtil.toString(type));
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(FlxRandom.chanceRoll(3)) {
      var w = width*0.3;
      var h = height/2;
      var px = x + FlxRandom.floatRanged(-w, w);
      var py = y + FlxRandom.floatRanged(0, h);
      ParticleKira.start(px, py);
    }
  }

  /**
   * アニメーションを登録
   **/

  private function _registAnim():Void {
    animation.add(ItemUtil.toString(ItemUtil.IType.Weapon), [0], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Armor), [1], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Scroll), [2], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Wand), [3], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Potion), [4], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Ring), [5], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Money), [6], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Food), [7], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Orb) + "0", [8], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Orb) + "1", [9], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Orb) + "2", [10], 1);
    animation.add(ItemUtil.toString(ItemUtil.IType.Orb) + "3", [11], 1);
  }
}
