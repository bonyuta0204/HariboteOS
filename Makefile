ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin -l ipl.lst

asmhead.bin: asmhead.asm
	nasm asmhead.asm -o asmhead.bin -l asmhead.lst

naskfunc.o : naskfunc.asm
	nasm -g -f elf naskfunc.asm -o naskfunc.o -l naskfunc.lst


bootpack.hrb: bootpack.c hrb.ld naskfunc.o hankaku.c
	i386-elf-gcc -march=i486 -m32 -nostdlib -T hrb.ld -g bootpack.c naskfunc.o hankaku.c -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img: ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy -i haribote.img haribote.sys ::

convHankakuTxt: convHankakuTxt.c
	gcc convHankakuTxt.c -o convHankakuTxt

hankaku.c: hankaku.txt convHankakuTxt.c
	./convHankakuTxt



img:
	make -r haribote.img

run:
	make img
	qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy

