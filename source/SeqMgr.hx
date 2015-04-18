package ;

import flixel.FlxG;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
	KeyInput; // キー入力待ち
	PlayerAct; // プレイヤーの行動
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
				if(_player.isKeyInput() == false) {
					// 移動した
					// 敵も移動する
					_enemies.forEachAlive(function(e:Enemy) e.requestMove());
					_state = State.PlayerAct;
				}
			case State.PlayerAct:
				if(_player.isTurnEnd()) {
					_state = State.EnemyAct;
				}
			case State.EnemyAct:
				var isEnd:Bool = true;
				_enemies.forEachAlive(function(e:Enemy) {
					if(e.isTurnEnd() == false) {
						isEnd = false;
					}
				});
				if(isEnd) {
					_state = State.TurnEnd;
				}
			case State.TurnEnd:
				// ターン終了
				_player.turnEnd();
				_enemies.forEachAlive(function(e:Enemy) e.turnEnd());
				_state = State.KeyInput;
		}
	}

}
