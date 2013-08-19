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

my @xy=$img[0]->Get('columns','rows');
if($crop) {
	$img[0]->Crop(y=>0, x=>0, width=>$xy[0]-$crop, heigth=>$xy[1]);
	$img[1]->Crop(y=>0, x=>$crop, width=>$xy[0], heigth=>$xy[1]);
}
@xy=$img[0]->Get('columns','rows');
foreach my $y(0..($xy[1]-1)) {
	next if not $y&1; # skip even lines
	#$img[0]->Composite(image=>$img[1], gravity=>"NorthEast", compose=>"Copy", x=>0, y=>$y, geometry=>"$xy[0]x1+0+$y");
	my @pix=$img[1]->GetPixels(width=>$xy[0], height=>1, x=>0, y=>$y, map=>"RGB", normalize=>"true");
	#print "$y $#pix\n";
	foreach my $x (0..($xy[0]-1)) {
		my @p=($pix[$x*3], $pix[$x*3+1], $pix[$x*3+2]);
		$img[0]->SetPixel(channel=>"RGB", x=>$x++, y=>$y, color=>\@p);
	}
}

#$img[0]->display();
$img[0]->Write($out);
