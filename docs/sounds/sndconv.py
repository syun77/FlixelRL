#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import os.path
import yaml
import shutil

def conv(wav, ogg, mp3):
	# ログレベルの設定
	opt = "-loglevel error"

	# oggにコンバート
	cmd = "ffmpeg %s -i %s -vcodec libtheora -acodec libvorbis %s"%(opt, wav, ogg)
	os.system(cmd)

	# mp3にコンバート
	cmd = "ffmpeg %s -i %s -f mp3 -acodec libmp3lame %s"%(opt, wav, mp3)
	os.system(cmd)

def main():
	# スクリプトがあるフォルダを取得
	dir = os.path.abspath(os.path.dirname(__file__))

	# 設定ファイル読み込み
	f = open("%s/%s"%(dir, "config.txt"))
	sounds = yaml.load(f)
	f.close

	# 元データのパスを作成
	dir_data = "%s/data"%dir

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
			wav = "%s/%s.wav"%(dir_data, k)
			mp3 = "%s/%s.mp3"%(dir_tmp, k)
			ogg = "%s/%s.ogg"%(dir_tmp, k)

			files.append(mp3)
			files.append(ogg)
			print "  %s.wav > %s.ogg, %s.mp3"%(k, k, k)

		conv(wav, ogg, mp3)

	# サウンドリスト書き込み
	fList = open("%s/%s"%(dir, "list.txt"), "w")
	# Flash環境
	fList.write('    <assets path="assets/sounds" if="flash" include="*.mp3">\n')
	for data in sounds:
		for k, v in data.items():
			fList.write("        <sound path=\"%s.mp3\" id=\"%s\" />\n"%(k, v))
	fList.write("    </assets>\n")
	# それ以外
	fList.write('    <assets path="assets/sounds" unless="flash" include="*.ogg">\n')
	for data in sounds:
		for k, v in data.items():
			fList.write("        <sound path=\"%s.ogg\" id=\"%s\" />\n"%(k, v))
	fList.write("    </assets>\n")
	fList.close

	# コピー実行
	print "start copy."
	# 出力フォルダ
	dst = dir + "/../../assets/sounds/"
	for f in files:
		src = f
		shutil.copy(src, dst)

	# 一時フォルダを削除
	shutil.rmtree(dir_tmp)

	# コンバート終了
	print "Done."

if __name__ == '__main__':
	main()
