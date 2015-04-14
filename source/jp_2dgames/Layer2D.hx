package jp_2dgames;


/**
 * ２次元マップクラス
 * @author syun
 */
import flixel.util.FlxPoint;
class Layer2D {
    public var m_Default:Int = 0; // デフォルト値
    public var m_OutOfRange:Int = -1; // 範囲外を指定した際のエラー値
    private var _width:Int;
    private var _height:Int;
    private var _pool:Map<Int, Int>;
    public var width(get_width, null):Int;
    public var height(get_height, null):Int;
    public var pool(get, null):Map<Int, Int>;

    /**
     * コンストラクタ
     * @param w 幅
     * @param h 高さ
     */

    public function new(w:Int=0, h:Int=0) {
        if(w > 0 && h > 0) {
            initialize(w, h);
        }
    }

    private function get_width() {
        return _width;
    }

    private function get_height() {
        return _height;
    }

    private function get_pool():Map<Int, Int> {
        return _pool;
    }

    public function initialize(w:Int, h:Int):Void {
        _pool = new Map<Int, Int>();
        _width = w;
        _height = h;
    }

    public function copy(layer:Layer2D):Void {
        layer.initialize(_width, _height);
        for (j in 0..._height) {
            for (i in 0..._width) {
                var v:Int = get(i, j);
                if (v != m_Default) {
                    layer.set(i, j, v);
                }
            }
        }
    }

    public function copyRectDestination(layer:Layer2D, destX:Int, destY:Int, srcX:Int = 0, srcY:Int = 0, srcW:Int = 0, srcH:Int = 0):Void {
        if(srcW <= 0) { srcW = layer.width; }
        if(srcH <= 0) { srcH = layer.height; }

        if(srcW == layer.width && srcH == layer.height) {
            // 高速コピー
            for(idx in layer.pool.keys()) {
                var i = idx%layer.width;
                var j = Math.floor(idx/layer.width);
                var v = layer.pool[idx];
                set(destX + i, destY + j, v);
            }
        }
        else {
            // 通常コピー
            for(j in 0...srcH) {
                for(i in 0...srcW) {
                    var v = layer.get(srcX + i, srcY + j);
                    set(destX + i, destY + j, v);
                }
            }
        }

    }

    /**
	 * 有効な範囲かどうかチェックする
	 * @param	x
	 * @param	y
	 * @return
	 */
    public function check(x:Int, y:Int):Bool {
        if (x < 0) { return false; }
        if (x >= _width) { return false; }
        if (y < 0) { return false; }
        if (y >= _height) { return false; }
        return true;
    }

    /**
	 * (x,y)の指定を一次元のインデックスに変換する
	 * @param	x
	 * @param	y
	 * @return
	 */
    public function getIdx(x:Int, y:Int):Int {
        return x + y * _width;
    }

    public function idxToX(idx:Int):Int {
        return idx%_width;
    }
    public function idxToY(idx:Int):Int {
        return Std.int(idx/_width);
    }

    public function get(x:Int, y:Int):Int {
        if (check(x, y) == false) {
            // 範囲外
            return m_OutOfRange;
        }

        var idx:Int = getIdx(x, y);
        if (_pool.exists(idx)) {
            return _pool[idx];
        }
        return m_Default;
    }

    public function set(x:Int, y:Int, val:Int):Void {
        if (check(x, y) == false) { return; }
        var idx:Int = getIdx(x, y);
        _pool[idx] = val;
    }

    /**
     * 指定の値が存在する座標を返す
     * @param v 検索する値
     * @return 座標を表す二次元ベクトル
     **/
    public function search(v:Int):FlxPoint {
        for(idx in _pool.keys()) {
            var val = _pool.get(idx);
            if(val == v) {
                var x:Int = idxToX(idx);
                var y:Int = idxToY(idx);
                return FlxPoint.get(x, y);
            }
        }
        return null;
    }

    /**
     * 指定の値が存在する数を返す
     * @param v 検索する値
     * @return 存在する数
     **/
    public function count(v:Int):Int {
        var ret:Int = 0;
        for(idx in _pool.keys()) {
            var val = _pool.get(idx);
            if(val == v) {
                ret++;
            }
        }
        return ret;
    }

    public function dump():Void {
        trace("<<Layer2D>> (width, height)=("+_width+", "+_height+")");
        for (j in 0..._height) {
            var s:String = "";
            for (i in 0..._width) {
                s += TextUtil.fillSpace(get(i, j), 3);
            }
            trace(s);
        }
    }
}
