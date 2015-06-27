#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import os.path
import yaml
import shutil

def conv(mp3, ogg):
	# ログレベルの設定
	opt = "-loglevel error"

	# oggにコンバート
	cmd = "ffmpeg %s -i %s -vcodec libtheora -acodec libvorbis %s"%(opt, mp3, ogg)
	os.system(cmd)

def main():
	# スクリプトがあるフォルダを取得
	dir = os.path.abspath(os.path.dirname(__file__))

	# 設定ファイル読み込み
	f = open("%s/%s"%(dir, "config_bgm.txt"))
	sounds = yaml.load(f)
	f.close

	# 元データのパスを作成
	dir_data = "%s/bgm"%dir

	# テンポラリフォルダのパスを作成
	dir_tmp = "%s/tmp"%dir

	# 一時フォルダを削除
	if(os.path.exists(dir_tmp)):
		shutil.rmtree(dir_tmp)

	# 出力フォルダ作成
	os.mkdir(dir_tmp)

	# コンバート開始
	files = []
	for data in sounds:
		for k, v in data.items():
			# mp3をテンポラリにコピー
			src = "%s/%s.mp3"%(dir_data, k)
			mp3 = "%s/%s.mp3"%(dir_tmp, k)
			shutil.copy(src, mp3)
			ogg = "%s/%s.ogg"%(dir_tmp, k)

			files.append(mp3)
			files.append(ogg)
			print "  %s.mp3 > %s.ogg"%(k, k)

		conv(mp3, ogg)

	# サウンドリスト書き込み
	fList = open("%s/%s"%(dir, "list_bgm.txt"), "w")
	# Flash環境
	fList.write('    <assets path="assets/music" if="flash" include="*.mp3">\n')
	for data in sounds:
		for k, v in data.items():
			fList.write("        <sound path=\"%s.mp3\" id=\"%s\" />\n"%(k, v))
	fList.write("    </assets>\n")
	# それ以外
	fList.write('    <assets path="assets/music" unless="flash" include="*.ogg">\n')
	for data in sounds:
		for k, v in data.items():
			fList.write("        <sound path=\"%s.ogg\" id=\"%s\" />\n"%(k, v))
	fList.write("    </assets>\n")
	fList.close

	# コピー実行
	print "start copy."
	# 出力フォルダ
	dst = dir + "/../../assets/music/"
	for f in files:
		src = f
		shutil.copy(src, dst)

	# 一時フォルダを削除
	shutil.rmtree(dir_tmp)

	# コンバート終了
	print "Done."

if __name__ == '__main__':
	main()
