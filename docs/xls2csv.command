#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/levels  header_enemy.txt
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/levels
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data
# アイテム
python xls2csv.py item.xlsx ../assets/levels

read Wait

# ターミナルを閉じる
killall Terminal
