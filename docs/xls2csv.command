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

#read Wait

# ターミナルを閉じる
#killall Terminal
