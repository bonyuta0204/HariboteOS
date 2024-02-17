NASM=nasm
GCC=i386-elf-gcc

all: haribote.img

# Bootloader
ipl.bin: ipl.asm
	$(NASM) ipl.asm -o ipl.bin -l ipl.lst

asmhead.bin: asmhead.asm
	$(NASM) asmhead.asm -o asmhead.bin -l asmhead.lst

naskfunc.o : naskfunc.asm
	$(NASM) -g -f elf naskfunc.asm -o naskfunc.o -l naskfunc.lst

hankaku.c: hankaku.txt convHankakuTxt.c
	./convHankakuTxt

convHankakuTxt: convHankakuTxt.c
	gcc convHankakuTxt.c -o convHankakuTxt


%.o: %.c
	$(GCC) -march=i486 -m32 -nostdlib -fno-builtin  -c $*.c -o $*.o

bootpack.hrb: bootpack.o hrb.ld naskfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o int.o fifo.o
	$(GCC) -march=i486 -m32 -nostdlib -fno-builtin -T hrb.ld -g bootpack.o naskfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o int.o fifo.o -o bootpack.hrb

# Main OS program
haribote.sys : asmhead.bin bootpack.hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img: ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy -i haribote.img haribote.sys ::



.PHONY: all img run clean

img:
	make -r haribote.img

# Run the image on QEMU
run:
	make img
	qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy

# Clean up
clean:
	rm -f *.bin *.o *.hrb *.sys *.img *.lst

