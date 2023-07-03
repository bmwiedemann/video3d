#!/usr/bin/perl -w
# Copyright 2013 Bernhard M. Wiedemann <bernhard+video3d at lsmod de>
# Licensed under GPL-2.0 (see COPYING)

use strict;
use Image::Magick;
# takes input from ffmpeg -i MVI_0020.MOV vid%04d.png

my $crop=18;
my $out=shift;
my @f=@ARGV;
if(@f == 1) { # convenience function to use next file as 2nd input
	$f[1]=$f[0];
	$f[1]=~s/(\d+)(\.png)$/sprintf("%04d", $1+1).$2/e;
}
if(@f != 2) { die "usage: $0 outimg img1 img2" }
print STDERR "processing image @f\n";

my @img;
foreach my $f (@f) {
	die "file $f not found" unless -r $f;
	my $img = new Image::Magick;
	$img->Read($f);
	push(@img, $img);
}

my @xy=$img[0]->Get('columns','rows'); # must be the same for both images
my @xynew=@xy; $xynew[0]-=$crop; $xynew[1]/=2;
if($crop) {
	$img[0]->Crop(y=>0, x=>0, width=>$xynew[0], heigth=>$xy[1]);
	$img[1]->Crop(y=>0, x=>$crop, width=>$xynew[0], heigth=>$xy[1]);
}
for (0..1) {
        $img[$_]->Resize(geometry=>"$xynew[0]x$xynew[1]!");
}
$img[0] = $img[0]->Montage(geometry=>"$xynew[0]x$xy[1]", gravity=>"north"); # grow canvas back to original height
$img[0]->Composite(
        compose=>'Over',
        image=>$img[1],
        x=>0,
        y=>$xynew[1],
);
$img[0]->Set(depth=>8);
#$img[0]->display();
$img[0]->Write($out);
