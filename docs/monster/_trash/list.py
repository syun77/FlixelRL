#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

def scale(inFile):
	# 入力ファイル
	src = "out/%s"%inFile
	# 出力ファイル
	dst = "out2x/%s"%inFile
	# 2倍にする
	SCALE = 2

	# コマンド文字列作成
	cmd = "/opt/local/bin/convert -filter box -resize %d%% %s %s"%(SCALE*100, src, dst)
	print cmd

	# 実行
	os.system(cmd)

def main(x, y, output):
	# ■まずは画像を切り抜く
	# 切り抜きサイズ
	SIZE = 16
	# 入力ファイル
	INPUT = "all.png"

	isExtra = False
	if output.find("#") > -1:
		# シャープが含まれていたら特殊な画像
		output = output.replace("#", "")
		isExtra = True

	for i in range(0, 1):
		# 3x5で並んでいる
		ox = (i / 3) * SIZE
		if isExtra:
			if i < 12:
				# oxを固定
				ox = 0
		else:
			# Down -> Left -> Up -> Right を
			# Left -> Up -> Right -> Down の順にしたい
			if i < 12:
				ox = (ox + SIZE)%(SIZE*4)

		oy = (i % 3) * SIZE
		ox += x
		oy += y

		# 出力ファイル
		out = "tmp/%s"%output

		# コマンド文字列作成
		cmd = "/opt/local/bin/convert "
		# 透過色を指定
		cmd += "-transparent '#476c6c' "
		cmd += "%s -crop '%dx%d+%d+%d' %s"%(INPUT, SIZE, SIZE, ox, oy, out)
		print cmd
		# 実行
		os.system(cmd);

	# 実行
	os.system(cmd)


tbl = [
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"#legion",
	"pumpkin_head",
	"skeleton_horse",
	"skeleton_dog",
	"floating_skull",
	"ghost",
	"zombie",
	"skeleton1",
	"skeleton2",
	"skeleton3",
	"liche",
	"mummy",
	"ghoul",
	"vampire",
	"wraith",
	"specter",
	"wight",
	"gnole1",
	"gnole2",
	"ogre1",
	"ogre2",
	"orc1",
	"orc2",
	"ratman1",
	"ratman2",
	"harpy_fly",
	"harpy_walk",
	"fairy",
	"snake_man",
	"lizardman1",
	"lizardman2",
	"goblin1",
	"goblin2",
	"goblin3",
	"goblin4",
	"minotaur1",
	"minotaur2",
	"yeti",
	"werewolf",
	"arachne",
	"mindflayer",
	"medousa",
	"homunculus",
	"invader",
	"dark_elf1",
	"dark_elf2",
	"dark_elf3",
	"dark_elf4",
	"dummy",
	"dummy",
	"golem",
	"crystal_golem",
	"iron_golem",
	"cat1",
	"cat2",
	"rat",
	"dog1",
	"dog2",
	"wolf",
	"snow_wolf",
	"pig",
	"doer",
	"bear",
	"polar_bear",
	"grizzy_bear",
	"stag",
	"doe",
	"panther",
	"snow_panther",
	"saber_tiger",
	"tiger",
	"gorilla",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"horse1",
	"horse2",
	"horse3",
	"horse4",
	"goat",
	"sheep",
	"bull",
	"cow",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"lizard",
	"snake",
	"frog",
	"toad",
	"wyvern",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"bird",
	"chicken",
	"bat",
	"jelly",
	"slime",
	"slug",
	"snail",
	"#tentacle",
	"#gelatinous_cube",
	"worm",
	"magot",
	"dummy",
	"dummy",
	"dummy",
	"dummy",
	"sea_serpent",
	"octopus_ground",
	"octopus_water",
	"#jellyfish",
	"eel_ground",
	"eel_water",
	"crab_ground",
	"crab_water",
	"gillman_ground",
	"gillman_water",
	"shellfish",
	"dummy",
	"fly",
	"mosquito",
	"scorpion",
	"spider",
	"bee",
	"worker_ant",
	"soldier_ant",
	"cockroach",
	"tick",
	"centipede",
	"pillbug",
	"mantis",
	"reaper",
	"#vine",
	"#fungus",
	"myconid",
	"#shrieker",
	"#gas_spore",
	"insectivorous_plant",
	"mandragora",
	"dummy",
	"dummy",
	"dummy",
	"beetle",
	"evil_eye",
	"imp",
	"goatman1",
	"goatman2",
	"lesser_fiend1",
	"lesser_fiend2",
	"gargoyle_walk",
	"gargoyle_fly",
	"vulture_demon",
	"succubus",
	"nightmare",
	"insect_demon",
	"empusa",
	"hairy_demon",
	"fire_demon",
	"water_demon",
	"earth_demon",
	"wind_demon",
	"poison_demon",
	"shadow_demon",
	"ice_demon",
]

for i, name in enumerate(tbl):
	x = 80 * (i % 12)
	y = 16 + 64 * (i / 12)
	main(x, y, name + ".png")

	# if name == "skeleton_horse":
		# break
