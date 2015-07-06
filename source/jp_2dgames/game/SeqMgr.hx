package jp_2dgames.game;

import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.gui.GuiBuyDetail;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.Generator.GenerateInfo;
import jp_2dgames.game.item.ThrowItem;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.GuiStatus;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.Actor.Action;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  KeyInput;       // キー入力待ち
  InventoryInput; // インベントリの操作中
  PlayerAct;      // プレイヤーの行動
  Firearm;        // 飛び道具
  Magicbullet;    // 魔法弾
  PlayerActEnd;   // プレイヤー行動終了
  EnemyRequestAI; // 敵のAI
  Move;           // 移動
  EnemyActBegin;  // 敵の行動開始
  EnemyAct;       // 敵の行動
  EnemyActEnd;    // 敵の行動終了
  TurnEnd;        // ターン終了
  NextFloor;      // 次のフロアに進むかどうか
  NextFloorWait;  // 次のフロアに進む（完了待ち）
  ShopOpen;       // ショップメニューを開く
  ShopRoot;       // ショップルートメニュー
  ShopSell;       // ショップ(売却)
  ShopBuy;        // ショップ(購入)
  GameClear;      // ゲームクリア
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr {

  // updateの戻り値
  public static inline var RET_NONE:Int = 0; // 何もなし
  public static inline var RET_GAMEOVER:Int = 1; // ゲームオーバー
  public static inline var RET_GAMECLEAR:Int = 2; // ゲームクリア

  private var _player:Player;
  private var _enemies:FlxTypedGroup<Enemy>;
  private var _inventory:Inventory;
  private var _guistatus:GuiStatus;
  private var _throwItem:ThrowItem;
  private var _csv:Csv;

  // 状態
  private var _state:State;
  private var _stateprev:State;

  /**
	 * コンストラクタ
	 **/
  public function new(state:PlayState, csv:Csv) {
    _player = state.player;
    _enemies = Enemy.parent;
    _inventory = Inventory.instance;
    _guistatus = state.guistatus;
    _csv = csv;

    _throwItem = new ThrowItem();

    _state = State.KeyInput;
    _stateprev = _state;

    // ターン数を初期化
    Global.initTurn();
  }

  /**
	 * 状態遷移
	 **/
  private function _change(s:State):Void {
    _stateprev = _state;
    _state = s;

    // ヘルプ情報の更新
    var help:Int = _guistatus.helpmode;
    switch(_state) {
      case State.KeyInput:
        help = GuiStatus.HELP_KEYINPUT;
      case State.InventoryInput:
        help = GuiStatus.HELP_INVENTORY;
      case State.PlayerAct:
      case State.Firearm:
      case State.Magicbullet:
      case State.PlayerActEnd:
      case State.EnemyRequestAI:
      case State.Move:
      case State.EnemyActBegin:
      case State.EnemyAct:
      case State.EnemyActEnd:
      case State.TurnEnd:
      case State.NextFloor:
        help = GuiStatus.HELP_DIALOG_YN;
      case State.NextFloorWait:
      case State.ShopOpen:
        help = GuiStatus.HELP_DIALOG_YN;
      case State.ShopRoot:
      case State.ShopSell:
        help = GuiStatus.HELP_SHOP_SELL;
      case State.ShopBuy:
        help = GuiStatus.HELP_SHOP_BUY;
      case State.GameClear:
    }

    _guistatus.changeHelp(help);
  }

  /**
	 * 更新
	 **/
  public function update():Int {
    var cnt:Int = 0;
    var bLoop:Bool = true;
    while(bLoop) {
      bLoop = proc();
      cnt++;
      if(cnt > 100) {
        break;
      }
    }

    if(_player.isDead()) {
      // 復活チェック
      var nCursor = Inventory.instance.searchItem(ItemConst.ORB3);
      if(nCursor >= 0) {
        // 白のオーブを持っているので復活
        Inventory.instance.delItem(nCursor);
        _player.addHp(9999);
        var name = ItemUtil.getParamString(ItemConst.ORB3, "name");
        Message.push2(Msg.ITEM_REVIVE, [name]);
      }
      else {
        _player.kill();
        return RET_GAMEOVER;
      }
    }
    else if(_state == State.GameClear) {
      // ゲームクリア
      return RET_GAMECLEAR;
    }

    return RET_NONE;
  }

  /**
	 * 敵をすべて動かす
	 **/
  private function _moveAllEnemy():Void {
    _enemies.forEachAlive(function(e:Enemy) {
      if(e.action == Action.Move) {
        e.beginMove();
      }
    });
  }

  /**
   * 次のフロアへ進む処理
   **/
  private function _nextFloor():Void {
    // 次のフロアへ進む
    Global.nextFloor();
    // ショップカウンタを増やす
    Global.nextShopAppearCount();
    // ナイトメアターン数を回復
    NightmareMgr.nextFloor();
  }

  /**
   * ゲームクリア判定
   **/
  private function _checkGameClear():Bool {
    var _check = function(itemid:Int) {
      // 指定したアイテムの存在チェック
      var nCursor = Inventory.instance.searchItem(itemid);
      return nCursor >= 0;
    };

    for(i in 0...4) {
      var itemid = ItemConst.ORB1 + i;
      if(_check(itemid) == false) {
        // 存在しないオーブがある
        return false;
      }
    }

    // すべてオーブが揃った
    return true;
  }

  private function proc():Bool {
    _player.proc();
    _enemies.forEachAlive(function(e:Enemy) e.proc());

    // ループフラグ
    var ret:Bool = false;

    switch(_state) {
      case State.KeyInput:
        // ■キー入力待ち
        switch(_player.action) {
          case Action.Act:
            // プレイヤー行動
            _player.beginAction();
            _change(State.PlayerAct);
            ret = true;
          case Action.Move:
            // 移動した
            _change(State.PlayerActEnd);
            ret = true;
          case Action.InventoryOpen:
            // インベントリを開く
            if(_inventory.checkOpen()) {
              // 開ける
              _inventory.setActive(true);
              _change(State.InventoryInput);
            }
            else {
              // 開けないのでキー入力に戻る
              _player.changeprev();
              Message.push2(Msg.INVENTORY_CANT_OPEN, null);
            }
          case Action.TurnEnd:
            // 足踏み待機
            _change(State.PlayerActEnd);
            // 制御を返して連続で回復しないようにする
            ret = false;
          default:
          // 何もしていない
        }

        // 敵の情報を表示するかどうかチェックする
        _guistatus.checkEnemyInfo();

      case State.InventoryInput:
        // ■イベントリ操作中
        switch(_inventory.proc()) {
          case Inventory.RET_CONTINUE:
            // 処理を続ける
          case Inventory.RET_CANCEL:
            // キー入力に戻る
            _player.changeprev();
            // 非表示
            _inventory.setActive(false);
            _change(State.KeyInput);
          case Inventory.RET_DECIDE:
            // ターン終了
            _player.standby();
            // 非表示
            _inventory.setActive(false);
            _change(State.PlayerActEnd);
          case Inventory.RET_THROW:
            // アイテムを投げた
            _player.standby();
            // 非表示
            _inventory.setActive(false);
            _throwItem.start(_player, _inventory.getTargetItem());
            _inventory.clearTargetItem();
            _change(State.Firearm);
          case Inventory.RET_SCROLL:
            // 巻物を読んだ
            _player.standby();
            // インベントリを非表示
            _inventory.setActive(false);
            var item = _inventory.getTargetItem();
            _inventory.clearTargetItem();
            if(item.type == IType.Scroll) {
              // 巻物
              if(ItemUtil.getParam(item.id, "atk") > 0) {
                // 魔法弾発射
                MagicShotMgr.startAllEnemy(_player.x, _player.y, item);
                _change(State.Magicbullet);
              }
              else {
                // 何か別の効果
                _change(State.PlayerActEnd);
              }
            }
            else {
              // 杖
              if(item != null) {
                // 魔法弾発射
                var px = Field.toWorldX(_player.xchip);
                var py = Field.toWorldY(_player.ychip);
                MagicShot.start(px, py, _player, null, item);
              }
              else {
                trace("wand is null");
              }
              _change(State.Magicbullet);
            }
        }

      case State.PlayerAct:
        // ■プレイヤーの行動
        if(_player.isTurnEnd()) {
          // 移動完了
          _change(State.PlayerActEnd);
          ret = true;
        }

      case State.Firearm:
        // ■飛び道具の移動
        if(_throwItem.isEnd()) {
          _change(State.PlayerActEnd);
        }

      case State.Magicbullet:
        // ■魔法弾の移動
        if(MagicShotMgr.isEnd()) {
          _change(State.PlayerActEnd);
        }

      case State.PlayerActEnd:
        // ■プレイヤー行動終了
        if(ExpMgr.get() > 0) {
          // 経験値獲得＆レベルアップ
          _player.addExp(ExpMgr.get());
        }
        _change(State.EnemyRequestAI);

      case State.EnemyRequestAI:
        // 敵に行動を要求する
        _enemies.forEachAlive(function(e:Enemy) e.requestMove());
        if(_player.isTurnEnd()) {
          _change(State.EnemyActBegin);
          ret = true;
        }
        else {
          // プレイヤーの移動を開始する
          _player.beginMove();
          // 敵も移動する
          _moveAllEnemy();
          _change(State.Move);
          ret = true;
        }

      case State.Move:
        if(_player.isTurnEnd()) {
          _change(State.EnemyActBegin);
          ret = true;
        }

      case State.EnemyActBegin:
        var bStart = false;
        _enemies.forEachAlive(function(e:Enemy) {
          if(bStart == false) {
            // 誰も行動していなければ行動する
            if(e.action == Action.Act) {
              e.beginAction();
              bStart = true;
            }
          }
        });
        ret = true;
        _change(State.EnemyAct);

      case State.EnemyAct:
        // ■敵の行動
        var isNext = true;
        var isActRemain = false;
        var isMoveRemain = false;
        _enemies.forEachAlive(function(e:Enemy) {
          switch(e.action) {
            case Action.ActExec:
              // アクション実行中
              isNext = false;
            case Action.MoveExec:
              // 移動中
              isNext = false;
            case Action.Act:
              // アクション実行待ち
              isActRemain = true;
            case Action.Move:
              // 移動待ち
              isMoveRemain = true;
            case Action.TurnEnd:
            // ターン終了
            default:
              // 通常ここに来ない
              trace('Error: Invalid action = ${e.action}');
          }
        });
        if(isNext) {
          // 敵が行動完了した
          if(isActRemain) {
            // 次の敵を動かす
            _change(State.EnemyActBegin);
          }
          else if(isMoveRemain) {
            // 移動待ちの敵がいるので動かしてやる
            _moveAllEnemy();
          }
          else {
            _change(State.EnemyActEnd);
          }
          ret = true;
        }
      case State.EnemyActEnd:
        // ■敵の行動終了
        if(ExpMgr.get() > 0) {
          // 経験値獲得＆レベルアップ
          _player.addExp(ExpMgr.get());
        }
        _change(State.TurnEnd);

      case State.TurnEnd:
        // ■ターン終了
        _procTurnEnd();
        ret = true;

      case State.NextFloor:
        // ■次のフロアに進む
        if(Dialog.isClosed()) {
          if(Dialog.getCursor() == 0) {
            // 次のフロアに進む
            FlxG.sound.play("foot");
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
              // フェードが完了したら次のフロアへ進む
              _nextFloor();
              FlxG.switchState(new PlayState());
            });
            _change(State.NextFloorWait);
          }
          else {
            // 階段を降りない
            _change(State.KeyInput);
            // 踏みつけているチップをクリア
            _player.endStompChip();
            _player.turnEnd();
          }
        }
      case State.NextFloorWait:
        // ■次のフロアに進む（完了待ち）
        // 何もしない

      case State.ShopOpen:
        // ■ショップメニュー表示
        var msg = Message.getText(Msg.MENU_SHOP_MSG);
        var cmd1 = Message.getText(Msg.MENU_SHOP_BUY);
        var cmd2 = Message.getText(Msg.MENU_SHOP_SELL);
        var cmd3 = Message.getText(Msg.MENU_SHOP_NOTHING);
        Dialog.open(Dialog.SELECT3, msg, [cmd1, cmd2, cmd3]);
        _change(State.ShopRoot);

      case State.ShopRoot:
        // ■ショップルートメニュー
        if(Dialog.isClosed()) {
          switch(Dialog.getCursor()) {
            case 0:
              // 購入
              if(GuiBuyDetail.isEmpyt()) {
                // 買えるアイテムがない
                _change(State.ShopOpen);
              }
              else {
                GuiBuyDetail.open();
                _change(State.ShopBuy);
              }
            case 1:
              // 売却
              if(_inventory.checkOpen()) {
                // インベントリを売却モードで開く
                _inventory.setActive(true, Inventory.EXECMODE_SELL);
                _change(State.ShopSell);
              }
              else {
                // 開けない
                _change(State.ShopOpen);
              }
            case -1, 2:
              // 何もしない
              // 踏みつけているチップをクリア
              _player.endStompChip();
              _player.turnEnd();
              _change(State.KeyInput);
          }
        }
      case State.ShopSell:
        // ■ショップメニュー表示(売却)
        switch(_inventory.proc()) {
          case Inventory.RET_CONTINUE:
            // 処理を続ける
          case Inventory.RET_CANCEL:
            // インベントリを閉じた
            // インベントリを非表示にする
            _inventory.setActive(false);
            _change(State.ShopOpen);
        }

      case State.ShopBuy:
        // ■ショップメニュー表示(購入)
        if(GuiBuyDetail.isClosed()) {
          _change(State.ShopOpen);
        }

      case State.GameClear:
        // ■ゲームクリア
    }

    return ret;
  }

  /**
   * 更新・ターン終了
   **/
  private function _procTurnEnd():Void {

    if(_checkGameClear()) {
      // ゲームクリアした
      _change(State.GameClear);
      return;
    }

    // トゲを切り替え
    Pit.turnEnd();

    // 経験値管理
    ExpMgr.turnEnd();

    // 敵の行動終了
    _enemies.forEachAlive(function(e:Enemy) e.turnEnd());
    switch(_player.stompChip) {
      case StompChip.Stairs:
        // 次のフロアに進む
        _change(State.NextFloor);
        var msg = Message.getText(Msg.MENU_NEXTFLOOR_MSG);
        var cmd1 = Message.getText(Msg.MENU_NEXTFLOOR);
        var cmd2 = Message.getText(Msg.MENU_STAY);
        Dialog.open(Dialog.SELECT2, msg, [cmd1, cmd2]);

      case StompChip.Shop:
        // ショップ
        _change(State.ShopOpen);

      case StompChip.None:

        var layer = cast(FlxG.state, PlayState).lField;
        // ナイトメア出現ターン数を減らす
        NightmareMgr.instance.nextTurn(layer);
        // ターン数を進める
        Global.nextTurn();
        {
          // ランダム敵の出現
          Generator.checkRandomEnemy(_csv, layer);
        }

        // キー入力に戻る
        _player.turnEnd();
        _change(State.KeyInput);
    }
  }
}
