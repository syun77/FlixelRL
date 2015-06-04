#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os



wav = "menu.wav"
mp3 = "menu.mp3"
ogg = "menu.ogg"
cmd = "ffmpeg -i %s -f mp3 -acodec libmp3lame %s"%(wav, mp3)
cmd = "ffmpeg -i %s -vcodec libtheora -acodec libvorbis %s"%(wav, ogg)


os.system(cmd)
