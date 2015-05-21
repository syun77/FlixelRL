#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
python xls2csv.py enemy.xlsx ../assets/levels/enemy.csv

# ターミナルを閉じる
killall Terminal
