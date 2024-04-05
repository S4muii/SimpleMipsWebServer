all:
	cpp -nostdinc -P main.asm main.i
	mips-linux-gnu-as -mips32r2 main.i -o main.o
	mips-linux-gnu-gcc main.o -o main -nostdlib -static
	rm main.i main.o
clean:
	rm main
