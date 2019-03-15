section .data:
	hello:		db "Hello, World!", 0Ah
	hello_len:	equ $ - hello

section .text:
global _start

_start:
	mov ecx, 6
	jmp loop
	loop:
		push rcx	; Can't push/pop 32-bit registers in 64-bit mode.

		mov eax, 4
		mov ebx, 1
		mov ecx, hello
		mov edx, hello_len
		int 80h

		pop rcx
		dec ecx
		cmp ecx, 0
		jne loop
	mov eax, 1
	mov ebx, 0
	int 80h
