ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

run:
	qemu-system-i386 -drive file=ipl.bin,format=raw,if=floppy
