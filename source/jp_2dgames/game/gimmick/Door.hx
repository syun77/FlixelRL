package jp_2dgames.game.gimmick;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.ParticleSmoke;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * ドア
 **/
class Door extends FlxSprite {
  // 親
  public static var parent:FlxTypedGroup<Door>;

  public static function start(type:Int, i:Int, j:Int):Void {
    var door:Door = parent.recycle();
    door._init(type, i, j);
  }
  public static function countDown():Void {
    parent.forEachAlive(function(door:Door) {
      door._countDonw();
    });
  }

  private var _xchip:Int;
  public var xchip(get, never):Int;
  public function get_xchip() {
    return _xchip;
  }
  private var _ychip:Int;
  public var ychip(get, never):Int;
  public function get_ychip() {
    return _ychip;
  }

  private var _hp:Int = 0;
  private var _hpText:FlxSprite;
  public var hpText(get, never):FlxSprite;
  private function get_hpText() {
    return _hpText;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic("assets/images/door.png");
    // 中心座標を基準に描画
    offset.set(width / 2, height / 2);

    // HP文字の作成
    _hpText = new FlxSprite().loadGraphic(Reg.PATH_SPR_FONT, true);
    for(i in 0...10) {
      _hpText.animation.add('${i}', [i], 1);
    }
    _hpText.color = FlxColor.PINK;

    // 消しておく
    kill();
  }

  override public function kill():Void {
    _hpText.visible = false;
    super.kill();
  }

  /**
   * 初期化
   **/
  private function _init(type:Int, i:Int, j:Int):Void {
    _xchip = i;
    _ychip = j;
    x = Field.toWorldX(i);
    y = Field.toWorldY(j);
    switch(type) {
      case Field.DOOR3:
        _hp = 3;
      case Field.DOOR5:
        _hp = 5;
      case Field.DOOR7:
        _hp = 7;
      default:
        trace('Warning: Invalid type (${i},${j}) = (${type}');
    }

    // HP文字更新
    _hpText.x = x - 8;
    _hpText.y = y - 8;
    _hpText.visible = true;
    _hpText.animation.play('${_hp}');
  }

  /**
   * 扉の耐久度を1つ減らす
   * @return 壊れたらtrue
   **/
  private function _countDonw():Bool {

    // エフェクト再生
    Particle.start(PType.Ring, x, y, FlxColor.AQUAMARINE);

    _hp--;
    if(_hp <= 0) {
      // 壊れる
      kill();
      Field.eraseDoor(xchip, ychip);
      ParticleSmoke.start("drill", x, y);
      Particle.start(PType.Circle, x, y, FlxColor.AQUAMARINE);
      return true;
    }

    // 壊れない
    // HP文字更新
    _hpText.animation.play('${_hp}');
    return false;
  }
}
