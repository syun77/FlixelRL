package ;

import flixel.FlxG;
import flixel.FlxSprite;
import DirUtil;

/**
 * プレイヤー
 */
class Player extends Actor {

	private var _target:Enemy = null;

	/**
	 * 生成
	 */
	public function new(X:Int, Y:Int) {
		super();

		var params = new Params();

		// 初期化
		init(X, Y, Dir.Down, params);

		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// キー入力待ち状態にする
		_state = Actor.State.KeyInput;
	}

	// アニメーション名を取得する
	private function getAnimName(bStop:Bool, dir:Dir):String {
		var pre = bStop ? "stop" : "walk";
		var suf = DirUtil.toString(dir);

		return pre + "-" + suf;
	}

	// アニメーションを再生
	private function changeAnim():Void {
		var name = getAnimName(_bStop, _dir);
		animation.play(name);
	}

	// 更新
	override public function update():Void {
		super.update();

		switch(_state) {
		case Actor.State.KeyInput:
			_updateStandby();

		case Actor.State.Standby:

		case Actor.State.ActBegin:

		case Actor.State.Act:
			_target.damage(30);
			_state = Actor.State.TurnEnd;

		case Actor.State.ActEnd:

		case Actor.State.MoveBegin:

		case Actor.State.Move:
			if(_updateWalk()) {
				_state = Actor.State.TurnEnd;
			}

		case Actor.State.MoveEnd:


		case Actor.State.TurnEnd:


		}

		changeAnim();
	}

	/**
	 * 更新・待機中
	 **/
	private function _updateStandby():Void {
		_bStop = true;
		var xnext = cast(_xnext, Int);
		var ynext = cast(_ynext, Int);
		if(FlxG.keys.pressed.LEFT) {
			// 左へ進む
			_dir = Dir.Left;
			xnext -= 1;
		}
		else if(FlxG.keys.pressed.UP) {
			// 上へ進む
			_dir = Dir.Up;
			ynext -= 1;
		}
		else if(FlxG.keys.pressed.RIGHT) {
			// 右へ進む
			_dir = Dir.Right;
			xnext += 1;
		}
		else if(FlxG.keys.pressed.DOWN) {
			// 下へ進む
			_dir = Dir.Down;
			ynext += 1;
		}
		else {
			// 移動しない
			return;
		}

		// 移動先に敵がいるかどうかチェック
		_target = null;
		var func = function(e:Enemy) {
			if(e.checkPosition(xnext, ynext)) {
				// 敵がいた
				_target = e;
			}
		}
		var enemies = cast(FlxG.state, PlayState).enemies;
		enemies.forEachAlive(func);

		if(_target != null) {
			// 敵がいるので攻撃する
			_xtarget = Std.int(xnext);
			_ytarget = Std.int(ynext);
			_state = Actor.State.ActBegin;
			return;
		}

		// 移動先チェック
		if(Field.isCollision(xnext, ynext) == false) {
			// 移動可能
			_xnext = xnext;
			_ynext = ynext;
			_bStop = false;
			_state = Actor.State.MoveBegin;
			_tMove = 0;
		}
	}

	/**
	 * アニメーションの登録
	 **/
	private function _registAnim():Void {
		// アニメーションとして読み込む
		loadGraphic("assets/images/player.png", true);

		// アニメーションを登録
		// 待機アニメ
		// アニメーション速度
		var speed = 2;
		animation.add(getAnimName(true, Dir.Left), [0, 1], speed);
		animation.add(getAnimName(true, Dir.Up), [4, 5], speed);
		animation.add(getAnimName(true, Dir.Right), [8, 9], speed);
		animation.add(getAnimName(true, Dir.Down), [12, 13], speed);

		// 歩きアニメ
		speed = 6;
		animation.add(getAnimName(false, Dir.Left), [2, 3], speed);
		animation.add(getAnimName(false, Dir.Up), [6, 7], speed);
		animation.add(getAnimName(false, Dir.Right), [10, 11], speed);
		animation.add(getAnimName(false, Dir.Down), [14, 15], speed);
	}
}
