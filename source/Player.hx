package ;

import flixel.FlxG;
import flixel.FlxSprite;
import DirUtil;

/**
 * 状態
 **/
enum State {
	Standby;
	Walk;
}

/**
 * プレイヤー
 */
class Player extends FlxSprite {

	private static inline var TIMER_WALK:Int = 16;

	// 状態
	private var _state:State = State.Standby;
	private var _tWalk:Int = 0;
	// 向き
	private var _dir:Dir = Dir.Down;
	// アニメーション状態
	private var _bStop = true;
	// 移動元座標
	private var _xprev:Float = 0;
	private var _yprev:Float = 0;
	// 移動先座標
	private var _xnext:Float = 0;
	private var _ynext:Float = 0;

	/**
	 * 生成
	 */
	public function new(X:Float, Y:Float) {
		super(X, Y);

		var chipX = Field.toChipX(X);
		var chipY = Field.toChipY(Y);
		_xprev = chipX;
		_yprev = chipY;
		_xnext = chipX;
		_ynext = chipY;
		x = Field.toWorldX(chipX);
		y = Field.toWorldY(chipY);

		// アニメーションとして読み込む
		loadGraphic("assets/images/player.png", true);
		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);
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
		case State.Standby:
			_updateStandby();

		case State.Walk:
			_updateWalk();

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

		// 移動先チェック
		if(Field.isCollision(xnext, ynext) == false) {
			// 移動可能
			_xnext = xnext;
			_ynext = ynext;
			_bStop = false;
			_state = State.Walk;
			_tWalk = 0;
		}
	}

	/**
	 * 更新・歩く
	 **/
	private function _updateWalk():Void {
		// 経過フレームの割合を求める
		var t = _tWalk / TIMER_WALK;
		// 移動方向を求める
		var dx = _xnext - _xprev;
		var dy = _ynext - _yprev;
		// 座標を線形補間する
		x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
		y = Field.toWorldY(_yprev) + (dy * Field.GRID_SIZE) * t;
		_tWalk++;
		if(_tWalk >= TIMER_WALK) {
			// 移動完了
			_state = State.Standby;
			_xprev = _xnext;
			_yprev = _ynext;
		}
	}

	/**
	 * アニメーションの登録
	 **/
	private function _registAnim():Void {
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
