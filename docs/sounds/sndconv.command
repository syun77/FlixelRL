#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
python sndconv.py

read Wait

# ターミナルを閉じる
killall Terminal
