package ;

import flixel.FlxG;
import flixel.FlxSprite;
import DirUtil;

/**
 * プレイヤー
 */
class Player extends FlxSprite {


	// 向き
	private var _dir:Dir = Dir.Down;
	// アニメーション状態
	private var _bStop = true;

	/**
	 * 生成
	 */
	public function new(X:Float, Y:Float) {
		super(X, Y);

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

		_bStop = true;
		velocity.set(0, 0);
		var speed = 50;
		if(FlxG.keys.pressed.LEFT) {
			_dir = Dir.Left;
			_bStop = false;
			velocity.x = -speed;
		}
		else if(FlxG.keys.pressed.UP) {
			_dir = Dir.Up;
			_bStop = false;
			velocity.y = -speed;
		}
		else if(FlxG.keys.pressed.RIGHT) {
			_dir = Dir.Right;
			_bStop = false;
			velocity.x = speed;
		}
		else if(FlxG.keys.pressed.DOWN) {
			_dir = Dir.Down;
			_bStop = false;
			velocity.y = speed;
		}

		changeAnim();
	}
}
