package ;
import flixel.group.FlxTypedGroup;
import jp_2dgames.CsvLoader;
import flixel.util.FlxPoint;
import flixel.FlxG;
import DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 敵クラス
 **/
class Enemy extends Actor {

	// 管理クラス
	public static var parent:FlxTypedGroup<Enemy> = null;
	// プレイヤー
	public static var target:Player = null;
	// 敵パラメータ
	public static var csv:CsvLoader = null;

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
	override public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool=false):Void {

		// ID取得
		_id = params.id;
		// アニメーション再生開始
		animation.play(Std.string(_id));

		if(bCreate) {
			// 生成なのでCSVからパラメータを取得する
			params.hp = csv.searchItemInt("id", '${_id}', "hp");
		}
		super.init(X, Y, Dir.Down, params);
		// 名前を設定
		_name = csv.searchItem("id", '${_id}', "name");
	}

	/**
	 * 更新
	 **/
	override public function proc():Void {
		switch(_state) {
		case Actor.State.KeyInput:
			// 何もしない

		case Actor.State.Inventory:
			// 何もしない

		case Actor.State.Standby:
			// 何もしない

		case Actor.State.ActBegin:
			// 何もしない

		case Actor.State.Act:
			target.damage(30);
			_change(Actor.State.TurnEnd);

		case Actor.State.ActEnd:
			// 何もしない

		case Actor.State.MoveBegin:
			// 何もしない

		case Actor.State.Move:
			if(_updateWalk()) {
				_change(Actor.State.TurnEnd);
			}

		case Actor.State.MoveEnd:
			// 何もしない

		case Actor.State.TurnEnd:
			// 何もしない
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
		var xnext = Std.int(pt.x);
		var ynext = Std.int(pt.y);
		pt.put();

		if(Field.isCollision(xnext, ynext)) {
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

		return dir;
	}

	/**
	 * 移動要求をする
	 **/
	public function requestMove():Void {
		var pt = FlxPoint.get(_xnext, _ynext);
		_dir = _aiMoveDir();
		pt = DirUtil.move(_dir, pt);
		var xnext = Std.int(pt.x);
		var ynext = Std.int(pt.y);
		pt.put();

		// 移動先にプレイヤーがいるかどうかをチェック
		if(target.checkPosition(xnext, ynext)) {
			// プレイヤーがいるので攻撃
			_change(Actor.State.ActBegin);
			return;
		}

		// 移動先チェック
		if(Field.isCollision(xnext, ynext) == false) {
			// 移動可能
			_xnext = xnext;
			_ynext = ynext;
			_change(Actor.State.MoveBegin);
			_tMove = 0;
		}
		else {
			// 移動できないのでターン終了
			_change(Actor.State.TurnEnd);
		}
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
