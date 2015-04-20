package ;
import flixel.util.FlxPoint;
import flixel.FlxG;
import DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 敵クラス
 **/
class Enemy extends Actor {

	// 敵ID
	private var _id:Int = 1;

	// プロパティ
	// 敵ID
	public var id(get_id, null):Int;
	private function get_id() {
		return _id;
	}

	public function new() {
		super();

		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// 消しておく
		kill();
	}

	/**
	 * 初期化
	 **/
	override public function init(X:Int, Y:Int, dir:Dir, params:Params):Void {

		// ID取得
		var id = params.id;

		// アニメーション再生開始
		animation.play(Std.string(id));
		_id = id;

		super.init(X, Y, Dir.Down, params);
	}

	/**
	 * 更新
	 **/
	override public function update():Void {
		super.update();

		switch(_state) {
		case Actor.State.KeyInput:

		case Actor.State.Standby:

		case Actor.State.Move:
			if(_updateWalk()) {
				_state = Actor.State.TurnEnd;
			}

		case Actor.State.TurnEnd:
		}
	}

	/**
	 * 移動方向を決める
	 **/
	private function _aiMoveDir():Dir {
		// 移動方向判定
		var player = cast(FlxG.state, PlayState).player;
		var dx = player.xchip - xchip;
		var dy = player.ychip - ychip;
		var func = function() {
			if(Math.abs(dx) > Math.abs(dy)) {
				if(dx < 0) {
					return Dir.Left;
				}
				else {
					return Dir.Right;
				}
			}
			else {
				if(dy < 0) {
					return Dir.Up;
				}
				else {
					return Dir.Down;
				}
			}
		}

		// 移動方向の判定実行
		var dir = func();

		// 移動先が壁かどうかチェックする
		var pt = FlxPoint.get(_xnext, _ynext);
		pt = DirUtil.move(dir, pt);
		trace(dx, dy);
		trace(pt);
		if(Field.isCollision(Std.int(pt.x), Std.int(pt.y))) {
			// 移動できない
			if(DirUtil.isHorizontal(dir)) {
				if(dy < 0) {
					dir = Dir.Up;
				}
				else {
					dir = Dir.Down;
				}
			}
			else {
				if(dx < 0) {
					dir = Dir.Left;
				}
				else {
					dir = Dir.Right;
				}
			}
		}

		pt.put();
		return dir;
	}

	/**
	 * 移動要求をする
	 **/
	public function requestMove():Void {
		var pt = FlxPoint.get(_xnext, _ynext);
		_dir = _aiMoveDir();
		pt = DirUtil.move(_dir, pt);

		// 移動先チェック
		if(Field.isCollision(Std.int(pt.x), Std.int(pt.y)) == false) {
			// 移動可能
			_xnext = Std.int(pt.x);
			_ynext = Std.int(pt.y);
			_state = Actor.State.Move;
			_tMove = 0;
		}
		else {
			// 移動できないのでターン終了
			_state = Actor.State.TurnEnd;
		}

		pt.put();
	}

	/**
	 * アニメーションの登録
	 **/
	private function _registAnim():Void {
		// 敵画像をアニメーションとして読み込む
		loadGraphic("assets/images/enemy.png", true);

		// アニメーションを登録
		var speed = 2;
		animation.add("1", [0, 1], speed); // スライム
		animation.add("2", [2, 3], speed); // コウモリ
		animation.add("3", [4, 5], speed); // ゴースト
		animation.add("4", [6, 7], speed); // ヘビ
		animation.add("5", [8, 9], speed); // ドクロ
	}
}
