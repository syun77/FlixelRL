package jp_2dgames.lib;

/**
 * テキストユーティリティ
 * @author syun
 */
class TextUtil {

  public function new() {
  }

  /**
     * ０埋めした数値文字列を返す
     * @param	n 元の数値
     * @param	digit ゼロ埋めする桁数
     * @return  ゼロ埋めした文字列
     */

  public static function fillZero(n:Int, digit:Int):String {
    var str:String = "" + n;
    return StringTools.lpad(str, "0", digit);
  }
  /**
     * スペース埋めした数値文字列を返す
     * @param	n
     * @param	digit
     * @return
     */

  public static function fillSpace(n:Int, digit:Int):String {
    var str:String = "" + n;
    return StringTools.lpad(str, " ", digit);
  }

  /**
   * 秒を「HH:MM:SS」形式の文字列に変換して返す
   **/
  public static function secToHHMMSS(sec:Int):String {
    var hour   = Std.int(sec / 60 / 60);
    var minute = Std.int(sec / 60);
    var second = sec % 60;

    return fillZero(hour, 2) + ":" + fillZero(minute, 2) + ":" + fillZero(second, 2);
  }

}

