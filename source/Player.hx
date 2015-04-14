package ;

import flixel.FlxG;
import flixel.FlxSprite;
import DirUtil;

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
		// 待機アニメ
		// アニメーション速度
		var speed = 3;
		animation.add(getAnimName(true, Dir.Left), [0, 1], speed);
		animation.add(getAnimName(true, Dir.Up), [4, 5], speed);
		animation.add(getAnimName(true, Dir.Right), [8, 9], speed);
		animation.add(getAnimName(true, Dir.Down), [12, 13], speed);

		// 歩きアニメ
		speed = 4;
		animation.add(getAnimName(false, Dir.Left), [2, 3], speed);
		animation.add(getAnimName(false, Dir.Up), [6, 7], speed);
		animation.add(getAnimName(false, Dir.Right), [10, 11], speed);
		animation.add(getAnimName(false, Dir.Down), [14, 15], speed);

		// アニメーションを再生
		changeAnim();

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
			_bStop = true;
			if(FlxG.keys.pressed.LEFT) {
				_dir = Dir.Left;
				_bStop = false;
			}
			else if(FlxG.keys.pressed.UP) {
				_dir = Dir.Up;
				_bStop = false;
			}
			else if(FlxG.keys.pressed.RIGHT) {
				_dir = Dir.Right;
				_bStop = false;
			}
			else if(FlxG.keys.pressed.DOWN) {
				_dir = Dir.Down;
				_bStop = false;
			}

			if(_bStop == false) {
				switch(_dir) {
					case Dir.Left:
						_xnext -= 1;
					case Dir.Up:
						_ynext -= 1;
					case Dir.Right:
						_xnext += 1;
					case Dir.Down:
						_ynext += 1;
				}
				_state = State.Walk;
				_tWalk = 0;
			}

		case State.Walk:
			var t = _tWalk / TIMER_WALK;
			var dx = _xnext - _xprev;
			var dy = _ynext - _yprev;
			x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
			y = Field.toWorldY(_yprev) + (dy * Field.GRID_SIZE) * t;
			_tWalk++;
			if(_tWalk >= TIMER_WALK) {
				_state = State.Standby;
				_xprev = _xnext;
				_yprev = _ynext;
			}

		}

		changeAnim();
	}
}
