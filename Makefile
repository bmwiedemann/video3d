help:
	@echo "make clean unpack conv vid F=input.vid"

#make unpack conv vid F=~/stuff/images/digicam/130818/MVI_0024.MOV
vid:
	cd out ; ffmpeg -i vid%04d.png -vcodec rawvideo -pix_fmt bgr24 ../outvid/vid002x.avi

conv1:
	cd in ; for f in * ; do ../mergepics.py ../out/$$f $$f ; done

conv: $(patsubst in/%.png,out/%.png,$(shell echo in/*.png))
out/%.png: in/%.png
	./mergepics.py $@ $<

test:
	./mergepics.py out/vid0118.png in/vid011[89].png

unpack:
	mkdir -p in out outvid
	cd in ; ffmpeg -i $F vid%04d.png

clean:
	rm -f out/* in/*
