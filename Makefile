all: floppy

main: main.asm
	nasm -f bin -o pong.bin main.asm
run: pong.bin
	qemu-system-i386 -fda pong.bin

floppy: main
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=pong.bin of=floppy.img seek=0 count=1 conv=notrunc

test:
	nasm -f bin -o bootcode.bin bootTest.asm
	qemu-system-i386 -fda bootcode.bin

clean:
	rm -f *.o
	rm -f *.img
	rm -f *.bin
