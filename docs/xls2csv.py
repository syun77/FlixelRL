#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlrd
import yaml
import re

# コンバート実行
def conv(sheet, outFile, const):
	print " [sheet] %s ... "%(sheet.name)

	# 数値判定用正規表現オブジェクト
	regex_num = re.compile("^\d+\.?\d*\Z")

	ROW_KEY  = 0 # 0行目はキー
	ROW_TYPE = 1 # 1行目は型
	ROW_DATA = 2 # 2行目以降はデータ
	nrows = sheet.nrows
	ncols = sheet.ncols
	row = 0
	types = [] # 型チェック用
	ret = ""
	while row < nrows:
		col = 0
		while col < ncols:
			if col > 0:
				ret += ","
			v = sheet.cell(row, col).value
			# 型情報を保存
			if row == ROW_TYPE:
				types.append(v)
			# 有効な値かどうかをチェック
			elif row >= ROW_DATA:
				if types[col] == "int":
					# 数値かどうかをチェック
					if bool(regex_num.match(str(v))) == False and str(v) != "":
						# 数値でない
						if not(v in const):
							# 定数でもない
							print "**********************************************************"
							msg = "Invalid integer: %s range(%s%d) val=%s"%(sheet.name, chr(65+col), row+1, v)
							print msg
							print "**********************************************************"
							raise Exception(msg)

			try:
				# 数値
				ret += str(int(v))
				#print v,
			except:
				# 文字列
				val = str(v.encode("utf-8"))
				if val in const:
					# 定数に置き換え
					val = str(const[val])
				else:
					# 改行文字を取り除く
					val = val.replace("\n", "")
				ret += val
				#print val
			col += 1
		row += 1
		#print
		ret += "\n"

	f = open(outFile, "w")
	f.write(ret)
	f.close
	print "   -> %s"%outFile


# メイン処理
def main(inFile, out, const):
	print "target: %s"%(inFile)
	book = xlrd.open_workbook(inFile)
	for sheet in book.sheets():
		conv(sheet, "%s/%s.csv"%(out, sheet.name), const)
	print "done."

def usage():
	print "Usage: xls2csv.py [input.xlsx] [output] [header.txt]"

if __name__ == '__main__':
	argc = len(sys.argv)
	const = {}
	if argc < 3:
		usage()
		quit()
	if argc >= 4:
		# 定数ファイル読み込み
		for fHeader in sys.argv[3].split(","):
			f = open(fHeader)
			data = yaml.load(f)["data"]
			const.update(data)
			f.close
	main(sys.argv[1], sys.argv[2], const)
	# main("enemy.xlsx", "/Users/syun/Desktop/FlixelRL/assets/levels/enemy.csv")
