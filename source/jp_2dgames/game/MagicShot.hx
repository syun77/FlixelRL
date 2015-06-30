package jp_2dgames.game;
import jp_2dgames.game.actor.Enemy;
import flixel.FlxG;
import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.game.item.ItemData;
import flash.display.BlendMode;
import flixel.util.FlxAngle;
import flixel.util.FlxRandom;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import flixel.FlxSprite;

private enum ShotType {
  Horming;     // ホーミング
  PlayerFront; // プレイヤーの前方に発射
  EnemyFront;  // 敵の前方に発射
}

/**
 * 敵に向かって飛んでいく魔法弾
 **/
class MagicShot extends FlxSprite {

  // 親
  public static var parent:MagicShotMgr = null;

  /**
   * 生成
   * @param X 開始座標(X)
   * @param Y 開始座標(Y)
   * @param actor 主体者
   * @param target 攻撃対象
   * @param item アイテム情報
   **/
  public static function start(X:Float, Y:Float, actor:Actor, target:Actor, item:ItemData):MagicShot {
    var ms:MagicShot = parent.recycle();
    ms.init(X, Y, actor, target, item);

    return ms;
  }

  // 最大移動速度
  public static inline var SPEED_MAX:Float = 1200;
  // 最大旋回速度
  public static inline var ROT_SPEED_MAX:Float = 45;

  // 主体者
  private var _actor:Actor;
  // ターゲット
  private var _target:Actor;
  // アイテム情報
  private var _item:ItemData;
  // ショットの種別
  private var _shotType:ShotType;
  // 消滅時にコールバックする関数
  private var _cbEnd:Void->Void;
  public function setEndCallback(func:Void->Void):Void {
    _cbEnd = func;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic("assets/images/effect.png", true);

    // アニメーション登録
    animation.add('play', [0], 1);

    animation.play('play');

    // スケール値設定
    scale.set(0.5, 0.5);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 加算ブレンド
    blend = BlendMode.ADD;
    // 色を変える
    color = FlxColor.YELLOW;

    // コールバック関数初期化
    _cbEnd = null;

    // いったん消す
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, actor:Actor, target:Actor, item:ItemData):Void {
    x = X;
    y = Y;
    _actor = actor;
    _target = target;
    _item = item;
    _cbEnd = null;

    if(item.type == IType.Scroll) {
      // ホーミングする
      _shotType = ShotType.Horming;
    }
    else {
      // 前方に発射するだけ
      if(actor.id == 0) {
        // プレイヤー
        _shotType = ShotType.PlayerFront;
      }
      else {
        // 敵
        _shotType = ShotType.EnemyFront;
      }
    }

    switch(_shotType) {
      case ShotType.Horming:
        // ランダムな速度を設定
        var speed = FlxRandom.floatRanged(20, 200);
        // 目標と反対側の角度を設定
        var deg = FlxAngle.angleBetween(this, _target, true);
        deg -= 180;

        velocity.x = speed * Math.cos(deg * FlxAngle.TO_RAD);
        velocity.y = speed * -Math.sin(deg * FlxAngle.TO_RAD);

      case ShotType.PlayerFront, ShotType.EnemyFront:
        // 前方に発射
        var v = DirUtil.getVector(actor.dir);
        var speed = 500;
        velocity.x = v.x * speed;
        velocity.y = v.y * speed;
        v.put();
    }
  }

  /**
   * 消滅時にコールバックされる関数
   **/
  override public function kill():Void {
    if(_cbEnd != null) {
      _cbEnd();
    }

    super.kill();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 拡縮アニメ
    var sc = FlxRandom.floatRanged(0.4, 0.5);
    scale.set(sc, sc);

    // 衝突判定
    switch(_shotType) {
      case ShotType.Horming:
        // ホーミング
        var dx = _target.x - x;
        var dy = _target.y - y;
        if(16*16 > dx*dx + dy*dy) {
          // 衝突
          MagicShotMgr.hitTarget(_target, _item);
          kill();
          return;
        }
        // ホーミング移動する
        _homing();

      case ShotType.PlayerFront:
        // 前方に移動（プレイヤー）
        var px = Std.int(Field.toChipX(x));
        var py = Std.int(Field.toChipY(y));
        // 敵との当たり判定をチェック
        var e = Enemy.getFromPositino(px, py);
        if(e != null) {
          // 必中
          var bAlwaysHit = true;
          e.hitItem(_actor, _item, bAlwaysHit);
          kill();
        }
        else if(Field.isThroughFirearm(px, py) == false) {
          // 壁に当たって消滅
          kill();
        }

      case ShotType.EnemyFront:
        // 前方に移動（敵）
        var px = Std.int(Field.toChipX(x));
        var py = Std.int(Field.toChipY(y));
        if(_target.checkPosition(px, py)) {
          // 必中
          var bAlwaysHit = true;
          _target.hitItem(_actor, _item, bAlwaysHit);
          kill();
        }
        else if(Field.isThroughFirearm(px, py) == false) {
          // 壁に当たって消滅
          kill();
        }
    }
  }

  /**
   * 目標に向かってホーミング移動する
   **/
  private function _homing():Void {
    var ax = velocity.x;
    var ay = velocity.y;
    var bx = _target.x - x;
    var by = _target.y - y;
    var speed = Math.sqrt(ax*ax + ay*ay);
    var deg = Math.atan2(-ay, ax) * FlxAngle.TO_DEG;
    // 角速度
    var dDeg = ROT_SPEED_MAX * Math.sin(speed/SPEED_MAX*90*FlxAngle.TO_RAD);
    // 加速
    speed += 30;
    if(speed > SPEED_MAX) {
      speed = SPEED_MAX;
    }

    var cos = (ax * bx + ay * by) / (Math.sqrt(ax*ax + ay*ay) * Math.sqrt(bx*bx + by*by));
    var cosDeg = Math.acos(cos) * FlxAngle.TO_DEG;
    if(Math.isNaN(cosDeg)) {
      cosDeg = 0;
    }
    if(cosDeg < dDeg) {
      dDeg = cosDeg;
    }
    var cross = ax * by - ay * bx;
    if(cross > 0) {
      // 反時計回り
      deg -= dDeg;
    }
    else {
      // 時計回り
      deg += dDeg;
    }
    velocity.x = speed * Math.cos(deg * FlxAngle.TO_RAD);
    velocity.y = speed * -Math.sin(deg * FlxAngle.TO_RAD);
  }
}
