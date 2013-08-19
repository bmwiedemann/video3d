#!/usr/bin/python
# Copyright 2013 Bernhard M. Wiedemann <bernhard+video3d at lsmod de>
# Licensed under GPL-2.0 (see COPYING)

# convert certain 2d video into 3d

import sys
import re
import gd

crop = 18
files = list(sys.argv)
outf = files.pop(0)  # drop program name
outf = files.pop(0)

if len(files) == 1:  # convenience function to use next file as 2nd input
    m = re.match(r"(.*?)(\d+)(\.png)$", files[0])
    files.append(m.group(1) + ("%04d" % (int(m.group(2)) + 1)) + m.group(3))

#print files, outf
if len(files) != 2:
    print "usage: mergepics.py outimg img1 img2"
    exit(1)
sys.stderr.write("processing image " + files[0] + "\n")

imgs = []
for f in files:
    img = gd.image(f)
    imgs.append(img)

xy = imgs[0].size()

if crop > 0:
    img = gd.image((xy[0] - crop, xy[1]), True)
    imgs[0].copyTo(img, (0, 0), (0, 0), (xy[0] - crop, xy[1]))
    imgs[0] = img
    img = gd.image((xy[0] - crop, xy[1]), True)
    imgs[1].copyTo(img, (0, 0), (crop, 0), (xy[0] - crop, xy[1]))
    imgs[1] = img

xy = imgs[0].size()

for y in range(0, xy[1] - 1):
    if y & 1 == 0:
        continue  # skip even lines
    imgs[1].copyTo(imgs[0], (0, y), (0, y), (xy[0], 1))
    #copyTo(image[, (dx,dy)[, (sx,sy)[, (w,h)]]])

imgs[0].writePng(outf)
