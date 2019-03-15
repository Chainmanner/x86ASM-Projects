; To compile:
;	nasm -f elf64 hello_world.asm
;	ld -o hello_world hello_world.o

section .data
	hello:		db "Hello, World!", 0Ah
	hello_len:	equ $ - hello

section .text
global _start

_start:
	mov eax, 4
	mov ebx, 1
	mov ecx, hello
	mov edx, hello_len
	int 80h

	mov eax, 1
	mov ebx, 0
	int 80h 
