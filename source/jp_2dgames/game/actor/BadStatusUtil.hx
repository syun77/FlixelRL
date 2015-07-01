package jp_2dgames.game.actor;

/**
 * バッドステータス定数
 **/
enum BadStatus {
  None;      // なし
  Confusion; // 混乱
  Sleep;     // 眠り
  Paralysis; // 麻痺
  Sickness;  // 病気
  Powerful;  // 元気いっぱい
  Anger;     // 怒り
  Poison;    // 毒
  Star;      // 無敵
  Closed;    // 封印
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {

  /**
   * バッドステータス定数を文字列に変換する
   **/
  public static function toString(stt:BadStatus):String {
    switch(stt) {
      case BadStatus.None: return "none";
      case BadStatus.Confusion: return "confusion";
      case BadStatus.Sleep: return "sleep";
      case BadStatus.Paralysis: return "paralysis";
      case BadStatus.Sickness: return "sickness";
      case BadStatus.Powerful: return "powerful";
      case BadStatus.Anger: return "anger";
      case BadStatus.Poison: return "poison";
      case BadStatus.Star: return "star";
      case BadStatus.Closed: return "closed";
    }
  }

  /**
   * バッドステータス文字列を定数に変換する
   **/
  public static function fromString(str:String):BadStatus {
    switch(str) {
      case "none": return BadStatus.None;
      case "confusion": return BadStatus.Confusion;
      case "sleep": return BadStatus.Sleep;
      case "paralysis": return BadStatus.Paralysis;
      case "sickness": return BadStatus.Sickness;
      case "powerful": return BadStatus.Powerful;
      case "anger": return BadStatus.Anger;
      case "poison": return BadStatus.Poison;
      case "star": return BadStatus.Star;
      case "closed": return BadStatus.Closed;
      default: return BadStatus.None;
    }
  }
}
