package jp_2dgames.game.gui;
import jp_2dgames.game.DirUtil.Dir;
import jp_2dgames.game.actor.Enemy;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * 敵の詳細情報
 **/
class GuiEnemy extends FlxSpriteGroup {

  // 基準座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 256 + 8;

  // 背景のサイズ
  private static inline var WIDTH = 212 - 8 * 2;
  private static inline var HEIGHT = 120;

  private static inline var IMG_X = 8;
  private static inline var IMG_Y = 8;
  private static inline var NAME_X = 48;
  private static inline var NAME_Y = 8;
  private static inline var HP_X = 48;
  private static inline var HP_Y = NAME_Y + 16;

  // 敵画像
  private var _imgEnemy:FlxSprite;
  // 敵の名前
  private var _txtName:FlxText;
  // 敵のHP
  private var _txtHp:FlxText;

  // 対象となる敵
  private var _enemy:Enemy = null;
  private var _enemyUID:Int = -1;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(POS_X, POS_Y);

    // 背景
    var sprBg = new FlxSprite(0, 0).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    sprBg.color = FlxColor.GRAY;
    sprBg.alpha = 0.4;
    this.add(sprBg);

    // 敵画像背景
    var sprBg2 = new FlxSprite(IMG_X, IMG_Y).makeGraphic(32, 32, FlxColor.WHITE);
    sprBg2.color = FlxColor.SILVER;
    this.add(sprBg2);
    // 敵画像
    _imgEnemy = new FlxSprite(IMG_X, IMG_Y);
    this.add(_imgEnemy);

    // 敵の名前
    _txtName = new FlxText(NAME_X, NAME_Y, 0, 160);
    _txtName.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtName);

    // 敵のHP
    _txtHp = new FlxText(HP_X, HP_Y, 0, 160);
    _txtHp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtHp);

    // 初期状態は非表示
    visible = false;
  }

  /**
   * 更新
   **/
  override public function update() {
    super.update();

    if(_enemy == null) {
      return;
    }

    _txtHp.text = 'HP: ${_enemy.params.hp}/${_enemy.params.hpmax}';
  }

  /**
   * 敵情報の設定
   **/
  public function setEnemy(e:Enemy):Void {
    _enemy = e;
    if(_enemy == null) {
      visible = false;
      _enemyUID = -1;
      return;
    }
    else {
      visible = true;
    }

    if(_enemyUID == _enemy.ID) {
      // 同じ敵なので更新不要
      // ただし向きは更新する
      _imgEnemy.animation.play(DirUtil.toString(_enemy.dir));
      return;
    }

    {
      var eid = _enemy.id;
      // 敵画像をアニメーションとして読み込む
      var name = Enemy.csv.searchItem("id", '${eid}', "image");
      _imgEnemy.loadGraphic('assets/images/monster/${name}.png', true);

      // アニメーションを登録
      var speed = 6;
      _imgEnemy.animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // 左
      _imgEnemy.animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // 上
      _imgEnemy.animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // 右
      _imgEnemy.animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // 下

      _imgEnemy.animation.play(DirUtil.toString(_enemy.dir));
    }

    _txtName.text = _enemy.name;
    _txtHp.text = 'HP: ${_enemy.params.hp}/${_enemy.params.hpmax}';

    // ユニークID更新
    _enemyUID = _enemy.ID;
  }
}
