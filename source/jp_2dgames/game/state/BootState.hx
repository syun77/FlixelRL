package jp_2dgames.game.state;
import haxe.Http;
import flixel.FlxG;
import flixel.FlxState;

/**
 * ゲーム起動時に一度だけ呼び出されるクラス
 **/
class BootState extends FlxState {
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    /*
//    var h = new Http("http://2dgames.jp/myphp/FlixelRL/post.php");
    var h = new Http("post.php");
    var post = "id=hoge&pass=123";
    h.setHeader( "Content-Type", "application/x-www-form-urlencoded" );
    h.setPostData(post);
    h.request(true);
    trace(h.responseData);
    */

    // セーブデータのロード
    GameData.init();
    GameData.load();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
  #if flash
    FlxG.switchState(new TitleState());
  #else
    FlxG.switchState(new NameEntryState());
//    FlxG.switchState(new PlayInitState());
//    FlxG.switchState(new TitleState());
  #end

    super.update();
  }
}
