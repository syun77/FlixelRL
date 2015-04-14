package jp_2dgames;

import StringTools;
import flixel.FlxG;
import openfl.Assets;

/**
 * CSV読み込みクラス
 **/
class CsvLoader2 {

    private var _filepath:String = "";
    private var _header: Array<String>;
    private var _datas: Array<Map<String, String>>;

    public function new(filepath:String = null) {
        if(filepath != null) {
            load(filepath);
        }
    }

    /**
     * CSVを読み込む
     * @param filepath CSVのファイルパス
     **/
    public function load(filepath:String):Void {
        _datas = new Array<Map<String, String>>();
        var text:String = Assets.getText(filepath);
        if(text == null) {
            FlxG.log.warn("CsvLoader.load() text is null. file:'" + filepath + "''");
            return;
        }
        _filepath = filepath;
        var row = 0;
        for(line in text.split("\n")) {
            if(line == "") { continue; }
            line = StringTools.trim(line);
            var arr:Array<String> = line.split(",");
            switch(row) {
            case 0:
                _header = line.split(",");
            default:
                var nId = 0;
                var col = 0;
                var data:Map<String, String> = new Map<String, String>();
                for(k in _header) {
                    var v:String = arr[col];
                    if(v == null) {
                        // データがなければ空文字にしておく
                        v = "";
                    }
                    if(k == "id") {
                        nId = Std.parseInt(v);
                    }
                    data.set(k, v);
                    col++;
                }
                _datas.push(data);
            }
            row++;
        }
    }

    /**
     * データ数を取得する
     * @return データ数
     **/
    public function size():Int {
        return _datas.length;
    }

    /**
     * 指定のIDが存在するかどうかチェックする
     * @param id id
     * @return 存在すればtrue
     **/
    public function hasId(id:Int):Bool {
        if(id < 0 || _datas.length <= id) {
            return false;
        }
        return true;
    }

    /**
     * 値を文字列として取得する
     * @param id id
     * @param key キー文字列
     * @return 値
     **/
    public function getString(id:Int, key:String):String {
        if(hasId(id) == false) {
            throw "Error: Not found id = " + id;
        }
        var data:Map<String, String> = _datas[id];
        if(data.exists(key) == false) {
            throw "Error: Not found key = " + key;
        }
        return data.get(key);
    }

    /**
     * 特定のキーを持つIDを検索する
     * @return 見つからなかったら-1
     **/
    public function searchID(key:String, value:String):Int {
        var i:Int = 0;
        for(data in  _datas) {
            if(data[key] == value) {
                return i;
            }
            i++;
        }

        return -1;
    }

    /**
     * 特定のキーに対応する値を持つ値を取得する
     * @return 見つからなかったらエラー
     **/
    public function searchItem(key:String, name:String, item:String):String {
        for(data in _datas) {
            if(data[key] == name) {
                return data[item];
            }
        }

        throw 'Error: Not found key="${key}" name="${name}" item="${item}"';
    }
    public function searchItemInt(key:String, name:String, item:String):Int {
        return Std.parseInt(searchItem(key, name, item));
    }
    public function searchItemFloat(key:String, name:String, item:String):Float {
        return Std.parseFloat(searchItem(key, name, item));
    }

    /**
     * 関数指定でIDを検索する
     * @param データをチェックする関数
     * @return 見つからなかったら-1
     **/
    public function foreachSearchID(func:Map<String,String>->Bool):Int {
        for(i in  0...size()+1) {
            if(hasId(i) == false) {
                continue;
            }
            var data = _datas[i];
            if(func(data)) {
                return i;
            }
        }
        return -1;
    }

    /**
     * 値を数値として取得する
     * @param id id
     * @param key キー文字列
     * @return 値
     **/
    public function getInt(id:Int, key:String):Int {
        return Std.parseInt(getString(id, key));
    }
    /**
     * 値を小数値として取得する
     * @param id id
     * @param key キー文字列
     * @return 値
     **/
    public function getFloat(id:Int, key:String):Float {
        return Std.parseFloat(getString(id, key));
    }
    public function dump():Void {
        trace("<CSVLoader> file='"+_filepath + "'");
        var str = "";
        for(s in _header) {
            str += s + ",";
        }
        trace(str);

        str = "";
        for(data in _datas) {
            str = "";
            for(d in data) {
                str += d + ",";
            }
            trace(str);
        }
    }

}
