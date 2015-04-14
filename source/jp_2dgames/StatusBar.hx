package jp_2dgames;

import flixel.ui.FlxBar;

/**
 * ステータスバー
 **/
class StatusBar extends FlxBar {

    private static inline var TIMER_DEFAULT = 100;
    private static inline var DECAY = 0.9;

    private var _prev:Float = 0;
    private var _next:Float = 0;
    private var _timer:Float = TIMER_DEFAULT;

    public function new(px:Float, py:Float, width:Int = 100, height:Int = 10, border:Bool = false, direction:Int = FlxBar.FILL_LEFT_TO_RIGHT) {
        super(px, py, direction, width, height, null, "", 0, 100, border);

    }

    /**
     * 値を設定
     * @param v 0〜100で指定します
     **/
    public function setPercent(v:Float):Void {

        if(v != _prev || (v == _prev && v != _next)) {

            if(_timer == 0 || v != _next) {
                // 開始
                _prev = percent;
                _next = v;
                _timer = TIMER_DEFAULT;
            }
            else {
                // 減少中
            }
        }

    }

    /**
     * 更新
     **/
    override function update():Void {
        super.update();

        if(_timer > 0) {
            _timer *= DECAY;
            if(_timer < 0.1) {
                _prev = _next;
                _timer = 0;
            }

            var d = _next - _prev;
            var d2 = d * (TIMER_DEFAULT - _timer) / TIMER_DEFAULT;
            var val = _prev + d2;
            percent = val;
        }
        else {
            percent = _prev;
        }
    }
}
