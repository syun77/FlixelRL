#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import shutil

# メイン処理
def main():
	# コピー元ファイル
	src = "000.tmx"
	# 開始番号
	first = 46
	last  = 50

	# 実行しているスクリプトのパスを取得する
	dir = os.path.dirname(__file__)
	target_dir = dir + "/../../assets/levels/"

	for i in range(first, last+1):
		src_path = target_dir + src
		dst_path = target_dir + "%03d.tmx"%i
		shutil.copyfile(src_path, dst_path)
		print "copy %s"%dst_path

	print "done."

if __name__ == '__main__':
	main()
