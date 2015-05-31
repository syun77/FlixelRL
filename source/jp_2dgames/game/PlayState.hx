package jp_2dgames.game;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import jp_2dgames.game.gui.GuiStatusDetail;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.gui.GuiStatus;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import flixel.util.FlxRandom;
import jp_2dgames.game.DirUtil.Dir;
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

  // CSVデータ
  private var _csv:Csv;

  // フロア数
  private var _floor:Int;
  public var floor(get, never):Int;
  public function get_floor() {
    return _floor;
  }

  // ステータス
  private var _guistatus:GuiStatus;
  public var guistatus(get, never):GuiStatus;
  public function get_guistatus() {
    return _guistatus;
  }

  /**
	 * 生成
	 */
  override public function create():Void {
    super.create();

    // 変数初期化
    _floor = 1;

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
      enemies.add(new Enemy());
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

    // 敵のHPバー登録
    enemies.forEach(function(e:Enemy) {
      this.add(e.hpBar);
    });

    // メッセージ生成
    var message = new Message(_csv.message);
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
    var partDamage = new FlxTypedGroup<ParticleDamage>(16);
    for(i in 0...partDamage.maxSize) {
      partDamage.add(new ParticleDamage());
    }
    this.add(partDamage);
    ParticleDamage.parent = partDamage;

    // 敵出現情報を計算
    var eIds = [];
    var eRatios = [];
    var sum:Int = 0;
    {
      var id = _csv.getEnemyAppearId(Global.getFloor());
      for(i in 0...5) {
        var eid = _csv.enemy_appear.getInt(id, 'e${i}');
        if(eid <= 0) {
          continue;
        }
        var ratio = _csv.enemy_appear.getInt(id, 'e${i}_r');
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
      _csv.item_appear.foreach(function(v:Map<String,String>) {
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
          var eid = func();
          if(eid > 0) {
            var e:Enemy = enemies.recycle();
            var params = new Params();
            params.id = eid;
            e.init(i, j, DirUtil.random(), params, true);
          }
        case Field.ITEM:
          // アイテムを生成
          var func = function() {
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
          var itemid = func();
          if(itemid == 0) {
            trace("Warning: Invalid item_appear.csv");
            itemid = 1;
          }
          var param = new ItemExtraParam();
          DropItem.add(i, j, itemid, param);
//          DropItem.addMoney(i, j, 100);
      }
    });

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
    _seq = new SeqMgr(this);

    // 状態を設定
    _state = State.Main;

    // TODO: デバッグ用のアイテムを追加
    if(false) {
      var param = new ItemExtraParam();
      for(i in 1...3) {
        Inventory.push(i, param);
        Inventory.push(i, param);
        Inventory.push(i, param);
        Inventory.push(i, param);
        Inventory.push(i, param);
        Inventory.push(i, param);
      }
      for(i in 1001...1007) {
        Inventory.push(i, param);
      }
      for(i in 1021...1027) {
        Inventory.push(i, param);
      }
    }

    // デバッグ情報設定
    FlxG.watch.add(player, "_state");
    FlxG.watch.add(player, "_stateprev");
    FlxG.watch.add(_seq, "_state");
    FlxG.watch.add(_seq, "_stateprev");

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
        }

      case State.Gameover:
        if(Key.press.A) {
          // ゲームデータを初期化
          Global.init();
          FlxG.switchState(new PlayState());
        }
    }

    // デバッグ処理
    updateDebug();
  }

  private function updateDebug():Void {
    #if neko
		if(FlxG.keys.justPressed.ESCAPE) {
			// ESCキーで終了する
			throw "Terminate.";
		}
	#end

    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save();
    }
    if(FlxG.keys.justPressed.L) {
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
  }
}