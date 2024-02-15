ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

run:
	qemu-system-i386 -fda ipl.bin
