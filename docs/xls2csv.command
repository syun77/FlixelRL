#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/levels  header_enemy.txt,header_item.txt
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/levels
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data
# アイテム
python xls2csv.py item.xlsx ../assets/levels header_item.txt
# イベントメッセージ
python xls2csv.py event.xlsx ../assets/events
# 実績
python xls2csv.py achievement.xlsx ../assets/data header_enemy.txt

# 定数ヘッダ出力
python export_const.py header_item.txt ../source/jp_2dgames/game/item
python export_const.py header_enemy.txt ../source/jp_2dgames/game/actor

#read Wait

# ターミナルを閉じる
#killall Terminal
