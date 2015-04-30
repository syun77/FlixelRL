package ;

import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
	KeyInput;       // キー入力待ち
	InventoryInput; // インベントリの操作中
	PlayerAct;      // プレイヤーの行動
	EnemyRequestAI; // 敵のAI
	Move;           // 移動
	EnemyActBegin;  // 敵の行動開始
	EnemyAct;       // 敵の行動
	TurnEnd;        // ターン終了
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr {
	private var _player:Player;
	private var _enemies:FlxTypedGroup<Enemy>;
	private var _inventory:Inventory;

	// 状態
	private var _state:State;

	/**
	 * コンストラクタ
	 **/
	public function new(state:PlayState) {
		_player = state.player;
		_enemies = Enemy.parent;
		_inventory = Inventory.instance;
		_state = State.KeyInput;
	}

	/**
	 * 更新
	 **/
	public function update():Void {
		var cnt:Int = 0;
		var bLoop:Bool = true;
		while(bLoop) {
			bLoop = proc();
			cnt++;
			if(cnt > 100) {
				break;
			}
		}
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
					case Actor.Action.Act:
						// プレイヤー行動
						_player.beginAction();
						_state = State.PlayerAct;
						ret = true;
					case Actor.Action.Move:
						// 移動した
						_state = State.EnemyRequestAI;
						ret = true;
					case Actor.Action.Inventory:
						// インベントリを開く
						_inventory.setActive(true);
						_state = State.InventoryInput;
					default:
						// 何もしていない
				}

			case State.InventoryInput:
				// ■イベントリ操作中
				if(_inventory.proc() == false) {
					// キー入力に戻る
					_player.changeprev();
					_inventory.setActive(false);
					_state = State.KeyInput;
				}

			case State.PlayerAct:
				// ■プレイヤーの行動
				if(_player.isTurnEnd()) {
					// 移動完了
					_state = State.EnemyRequestAI;
					ret = true;
				}
			case State.EnemyRequestAI:
				// 敵に行動を要求する
				_enemies.forEachAlive(function(e:Enemy) e.requestMove());
				if(_player.isTurnEnd()) {
					_state = State.EnemyActBegin;
					ret = true;
				}
				else {
					// プレイヤーの移動を開始する
					_player.beginMove();
					// 敵も移動する
					_enemies.forEachAlive(function(e:Enemy) {
						if(e.action == Actor.Action.Move) {
							e.beginMove();
						}
					});
					_state = State.Move;
					ret = true;
				}

			case State.Move:
				if(_player.isTurnEnd()) {
					_state = State.EnemyActBegin;
					ret = true;
				}

			case State.EnemyActBegin:
				_enemies.forEachAlive(function(e:Enemy) {
					if(e.action == Actor.Action.Act) {
						e.beginAction();
					}
				});
				ret = true;
				_state = State.EnemyAct;

			case State.EnemyAct:
				// ■敵の行動
				var isEnd:Bool = true;
				_enemies.forEachAlive(function(e:Enemy) {
					if(e.isTurnEnd() == false) {
						// まだ終わっていない敵がいる
						isEnd = false;
					}
				});
				if(isEnd) {
					// 敵がすべて移動完了した
					_state = State.TurnEnd;
					ret = true;
				}
			case State.TurnEnd:
				// ■ターン終了
				_player.turnEnd();
				_enemies.forEachAlive(function(e:Enemy) e.turnEnd());
				_state = State.KeyInput;
				ret = true;
		}

		return ret;
	}

}
