package ;

import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
	KeyInput; // キー入力待ち
	PlayerAct; // プレイヤーの行動
	EnemyRequestAI; // 敵のAI
	Move; // 移動
	EnemyAct; // 敵の行動
	TurnEnd; // ターン終了
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr {
	private var _player:Player;
	private var _enemies:FlxTypedGroup<Enemy>;

	// 状態
	private var _state:State;

	/**
	 * コンストラクタ
	 **/
	public function new(state:PlayState) {
		_player = state.player;
		_enemies = state.enemies;
		_state = State.KeyInput;
	}

	/**
	 * 更新
	 **/
	public function update():Void {
		switch(_state) {
			case State.KeyInput:
				// ■キー入力待ち
				switch(_player.action) {
					case Actor.Action.Act:
						// プレイヤー行動
						_player.beginAction();
						_state = State.PlayerAct;
					case Actor.Action.Move:
						// 移動した
						_state = State.EnemyRequestAI;
					default:
						// 何もしていない
				}
			case State.PlayerAct:
				// ■プレイヤーの行動
				if(_player.isTurnEnd()) {
					// 移動完了
					_state = State.EnemyRequestAI;
				}
			case State.EnemyRequestAI:
				// 敵に行動を要求する
				_enemies.forEachAlive(function(e:Enemy) e.requestMove());
				// プレイヤーの移動を開始する
				_player.beginMove();
				_state = State.Move;

			case State.Move:
				if(_player.isTurnEnd()) {
					_state = State.EnemyAct;
				}

			case State.EnemyAct:
				// ■敵の行動
				var isEnd:Bool = true;
				_enemies.forEachAlive(function(e:Enemy) {
					if(e.isTurnEnd() == false) {
						// 移動完了
						isEnd = false;
					}
				});
				if(isEnd) {
					// 敵がすべて移動完了した
					_state = State.TurnEnd;
				}
			case State.TurnEnd:
				// ■ターン終了
				_player.turnEnd();
				_enemies.forEachAlive(function(e:Enemy) e.turnEnd());
				_state = State.KeyInput;
		}
	}

}
