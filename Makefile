ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

haribote.sys: haribote.asm
	nasm haribote.asm -o haribote.sys

haribote.img: ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy -i haribote.img haribote.sys ::

img:
	make -r haribote.img

run:
	make img
	qemu-system-i386 -drive file=ipl.bin,format=raw,if=floppy

