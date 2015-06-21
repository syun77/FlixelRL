package jp_2dgames.game;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.ParticleEnemy;
import flixel.util.FlxRandom;
import jp_2dgames.game.particle.ParticleMessage;
import jp_2dgames.game.particle.ParticleRecovery;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.gui.GuiStatus;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import jp_2dgames.game.item.ItemData;
import flixel.group.FlxTypedGroup;
import jp_2dgames.lib.Layer2D;
import flixel.FlxSprite;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxG;
import flixel.FlxState;
import jp_2dgames.game.Save;

/**
 * 状態
 **/
private enum State {
  FloorStart; // フロア開始演出
  Main; // メイン処理
  Gameover; // ゲームオーバー
}

/**
 * メインゲーム
 */
class PlayState extends FlxState {
  // プレイヤー情報
  private var _player:Player;
  public var player(get, never):Player;
  private function get_player() {
    return _player;
  }
  // マップ情報
  private var _lField:Layer2D;
  public var lField(get, never):Layer2D;
  private function get_lField() {
    return _lField;
  }

  // シーケンス管理
  private var _seq:SeqMgr;

  // 状態
  private var _state:State;

  // 背景
  private var _back:FlxSprite;

  // フロア開始演出用テキスト
  private var _txtFloor:FlxText;
  // フロア開始演出用の黒い四角形
  private var _bgFade:FlxSprite;

  // CSVデータ
  private var _csv:Csv;

  // ステータス
  private var _guistatus:GuiStatus;
  public var guistatus(get, never):GuiStatus;
  public function get_guistatus() {
    return _guistatus;
  }

  // ターン数
  private var _turn:Int = 0;

  // デバッグ用アイテム
  private var _debugItem:DropItem;
  // デバッグ用敵
  private var _debugEnemy:Enemy;

  /**
	 * 生成
	 */
  override public function create():Void {
    super.create();

    // 状態を設定
    _state = State.FloorStart;
    // フロア開始演出スタート
    _bgFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    _txtFloor = new FlxText(FlxG.width/3.2, FlxG.height/2.5, 256, "", 48);
    _txtFloor.text = 'Floor ${Global.getFloor()}';
    _txtFloor.color = FlxColor.WHITE;
    this.add(_bgFade);
    this.add(_txtFloor);
    FlxG.camera.fade(FlxColor.BLACK, 0.5, true, function() {
      FlxG.camera.shake(0.0002*Global.getFloor(), 0.5, function() {
        // 暗転解除
        this.remove(_bgFade);
        this.remove(_txtFloor);

        // インスタンス生成
        _start();
        FlxG.camera.fade(FlxColor.BLACK, 0.3, true, function() {
          // フェード終了
          _state = State.Main;
        });
      });
    });

  }

  private function _start() {
    // CSV読み込み
    _csv = new Csv();
    Enemy.csv = _csv.enemy;
    ItemUtil.csvConsumable = _csv.itemConsumable;
    ItemUtil.csvEquipment = _csv.itemEquipment;

    // マップ読み込み
    var tmx = new TmxLoader();
    tmx.load(Global.getFloorMap());
    var layer = tmx.getLayer(0);
    // 背景レイヤーを生成
    _lField = new Layer2D();
    // 背景画像を登録
    _back = new FlxSprite();
    this.add(_back);

    // 階段の位置をランダムに配置する
    Field.randomize(layer, Global.getFloor(), _csv);

    // フィールドを登録
    setFieldLayer(layer);

    // アイテム管理生成
    var items = new FlxTypedGroup<DropItem>(128);
    for(i in 0...items.maxSize) {
      items.add(new DropItem());
    }
    this.add(items);
    DropItem.parent = items;

    // 敵管理生成
    var enemies = new FlxTypedGroup<Enemy>(32);
    for(i in 0...enemies.maxSize) {
      var e = new Enemy();
      // IDに配列要素を設定
      e.ID = i;
      enemies.add(e);
    }
    this.add(enemies);
    Enemy.parent = enemies;

    // プレイヤー生成
    {
      var pt = layer.search(Field.PLAYER);
      _player = new Player(Std.int(pt.x), Std.int(pt.y), _csv.player);
      this.add(_player);
      pt.put();
    }
    this.add(_player.cursor);

    // 敵からアクセスしやすいようにする
    Enemy.target = _player;

    // バステアイコン登録
    this.add(_player.balloon);
    // 敵のHPバー・バステアイコン登録
    enemies.forEach(function(e:Enemy) {
      this.add(e.hpBar);
      this.add(e.balloon);
    });

    // 魔法弾作成
    MagicShot.parent = new MagicShotMgr(enemies.maxSize);
    for(i in 0...MagicShot.parent.maxSize) {
      var ms = new MagicShot();
      MagicShot.parent.add(ms);
    }
    this.add(MagicShot.parent);

    // メッセージ生成
    var message = new Message(_csv.message, _csv.hint);
    Message.instance = message;

    // ステータス表示
    _guistatus = new GuiStatus();
    this.add(_guistatus);

    // パーティクル
    var particles = new FlxTypedGroup<Particle>(256);
    for(i in 0...particles.maxSize) {
      particles.add(new Particle());
    }
    this.add(particles);
    Particle.parent = particles;

    // パーティクル（ダメージ数値）
    {
      var part = new FlxTypedGroup<ParticleDamage>(16);
      for(i in 0...part.maxSize) {
        part.add(new ParticleDamage());
      }
      this.add(part);
      ParticleDamage.parent = part;

    }

    // パーティクル（HP回復数値）
    {
      var part = new FlxTypedGroup<ParticleRecovery>(4);
      for(i in 0...part.maxSize) {
        part.add(new ParticleRecovery());
      }
      this.add(part);
      ParticleRecovery.parent = part;
    }

    // パーティクル（メッセージ）
    {
      var part = new FlxTypedGroup<ParticleMessage>(8);
      for(i in 0...part.maxSize) {
        part.add(new ParticleMessage());
      }
      this.add(part);
      ParticleMessage.parent = part;
    }

    // パーティクル（敵の出現）
    {
      var part = new FlxTypedGroup<ParticleEnemy>(Enemy.parent.maxSize);
      for(i in 0...part.maxSize) {
        part.add(new ParticleEnemy());
      }
      this.add(part);
      ParticleEnemy.parent = part;
    }

    // 敵やアイテムを自動配置
    Generator.exec(_csv, layer);

    // メッセージを描画に登録
    this.add(message);

    // インベントリ
    var inventory = new Inventory();
    this.add(inventory);
    Inventory.instance = inventory;
    inventory.setGuiStatus(_guistatus);
    // アイテムデータ設定
    Global.setItemList();

    // シーケンス管理
    _seq = new SeqMgr(this, _csv);

    // デバッグ用アイテム
    _debugItem = new DropItem();
    _debugItem.alpha = 0.5;
    this.add(_debugItem);

    // デバッグ情報設定
    FlxG.watch.add(player, "_state");
    FlxG.watch.add(player, "_stateprev");
    FlxG.watch.add(_seq, "_state");
    FlxG.watch.add(_seq, "_stateprev");
    FlxG.watch.add(this, "_turn");

    //		FlxG.debugger.visible = true;
    FlxG.debugger.toggleKeys = ["ALT"];
    //		FlxG.debugger.drawDebug = true;
  }

  /**
	 * フィールド情報を設定する
   **/
  public function setFieldLayer(layer:Layer2D) {
    // フィールド情報をコピー
    _lField.copy(layer);

    // 背景画像を作成
    Field.createBackground(_lField, _back);
    // コリジョンレイヤーを登録
    Field.setCollisionLayer(_lField);
  }

  /**
	 * 破棄
	 */
  override public function destroy():Void {
    Particle.parent = null;
    ParticleDamage.parent = null;
    ParticleRecovery.parent = null;
    ParticleEnemy.parent = null;
    MagicShot.parent = null;
    DropItem.parent = null;
    Enemy.parent = null;
    Enemy.csv = null;
    Message.instance = null;
    Inventory.instance = null;
    ItemUtil.csvConsumable = null;
    ItemUtil.csvEquipment = null;
    super.destroy();
  }

  /**
	 * 更新
	 */
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.FloorStart:

      case State.Main:
        // シーケンス更新
        if(_seq.update() == false) {
          // ゲームオーバー
          _state = State.Gameover;
          var spr = new FlxSprite(0, 240-32).makeGraphic(640, 64, FlxColor.BLACK);
          spr.alpha = 0.5;
          this.add(spr);
          var txt = new FlxText(216+2, 212+2, 0, 640);
          txt.setFormat(Reg.PATH_FONT, 48);
          txt.color = FlxColor.BLACK;
          txt.text = "GAME OVER";
          this.add(txt);
          var txt2 = new FlxText(txt.x-2, txt.y-2, 0, 640);
          txt2.setFormat(Reg.PATH_FONT, 48);
          txt2.color = FlxColor.WHITE;
          txt2.text = "GAME OVER";
          this.add(txt2);

          Snd.playSe("gameover");
        }

      case State.Gameover:
        if(Key.press.A) {
          // ゲームデータを初期化
          Global.init();
          FlxG.switchState(new PlayState());
        }
    }

    if(_state == State.Main) {
      // デバッグ処理
      updateDebug();
    }
  }

  /**
   * デバッグ処理
   **/
  private function updateDebug():Void {
#if neko
		if(FlxG.keys.justPressed.ESCAPE) {
			// ESCキーで終了する
			throw "Terminate.";
		}
#end

    // ターン数を保持
    _turn = Global.getTurn();

    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save();
    }
    if(FlxG.keys.justPressed.A) {
      // ロード
      Save.load();
    }
    if(FlxG.keys.justPressed.R) {
      // リスタート
      FlxG.switchState(new PlayState());
    }
    if(FlxG.keys.justPressed.D) {
      // 自爆
      _player.damage(9999);
    }
    if(FlxG.keys.justPressed.H) {
      // HP回復
      _player.addHp(9999);
    }
    if(FlxG.keys.justPressed.TWO) {
      // 次のフロアに進む
      Global.nextFloor();
    }
    if(FlxG.keys.justPressed.ONE) {
      // 1つ前のフロアに進む
      Global.backFloor();
    }
    if(FlxG.keys.justPressed.T) {
      // 魔法弾発射テスト
      var param = new ItemExtraParam();
      var item = new ItemData(33, param);
      MagicShotMgr.start(_player.x, _player.y, item);
    }

    // アイテム配置デバッグ機能
    var itemtype = ItemUtil.getDebugItemType();
    if(itemtype != IType.None) {
      var i = Field.getMouseChipX();
      var j = Field.getMouseChipY();
      var itemid = ItemUtil.random(itemtype);
      var params = new ItemExtraParam();
      _debugItem.init(i, j, itemtype, itemid, params);
      _debugItem.revive();
      if(FlxG.mouse.justPressed) {
        var pt = FlxPoint.get(i, j);
        if(DropItem.checkDrop(pt, i, j)) {
          // 置ける
          i = Std.int(pt.x);
          j = Std.int(pt.y);
          if(itemtype == IType.Money) {
            DropItem.addMoney(i, j, itemid);
          }
          else {
            params.condition = FlxRandom.intRanged(5, 15);
            DropItem.add(i, j, itemid, params);
          }
        }
        pt.put();
      }
    }
    else {
      _debugItem.kill();
    }

    // プレイヤー移動デバッグ機能
    if(FlxG.keys.pressed.NINE) {
      if(FlxG.mouse.justPressed) {
        var i = Field.getMouseChipX();
        var j = Field.getMouseChipY();
        _player.setDebugPosition(i, j);
      }
    }

    // 敵操作デバッグ機能
    if(FlxG.keys.pressed.EIGHT) {
      if(FlxG.mouse.justPressed) {
        var i = Field.getMouseChipX();
        var j = Field.getMouseChipY();
        var e = Enemy.getFromPositino(i, j);
        if(e != null) {
          // つかみ開始
          _debugEnemy = e;
        }
      }
    }
    if(_debugEnemy != null) {
      if(_debugEnemy.exists == false) {
        // 死亡したのでつかみ終了
        _debugEnemy = null;
      }
      else {
        // 敵を移動
        var i = Field.getMouseChipX();
        var j = Field.getMouseChipY();
        _debugEnemy.setDebugPosition(i, j);
        if(FlxG.mouse.justReleased) {
          // つかみ終了
          _debugEnemy = null;
        }
      }
    }
  }
}