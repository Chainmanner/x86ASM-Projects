; To compile:
;	nasm -f elf64 sha-2.asm
;	ld -o convert sha-2.o

section .data

	h0:		dd 0x6a09e667
	h1:		dd 0xbb67ae85
	h2:		dd 0x3c6ef372
	h3:		dd 0xa54ff53a
	h4:		dd 0x510e527f
	h5:		dd 0x9b05688c
	h6:		dd 0x1f83d9ab
	h7:		dd 0x5be0cd19

	k:		dd 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
	w:		times 64 dd 0xFFFFFFFF

	origMsg:	db "here comes f l a m e b o i", 0
	origMsg_len:	equ $ - origMsg
	msg:		times 128 db 0xFF
	msg_len:	dq 0xAAAAAAAAAAAAAAAA

section .bss

	a:		resq 1
	b:		resq 1
	c:		resq 1
	d:		resq 1
	e:		resq 1
	f:		resq 1
	g:		resq 1
	h:		resq 1

section .text
global _start

; TODO: The code only works for messages of length < 55 (64 - 1 - 8)
_start:
	push origMsg
	push msg
	call copyStr

	push msg
	call strLen
	dec rax
	mov qword [msg_len], rax
	mov rcx, rax
	xor rax, rax

	; Pad out the input message.
	; TODO: Problematic.
	mov byte [msg+rcx], 0x80
	inc rcx
	mov rbx, 56
	sub rbx, rcx
	padLoop1:
		mov byte [msg+rcx], 0x00	; CHANGED FROM 0x00
		inc rcx
		mov rax, rcx
		dec rbx
		cmp rbx, 0
		jg padLoop1

	push 8
	push msg_len
	call swapEndian

	; NOTE: To show a list of bytes in GDB starting from &msg, use:		x /64bx &msg

	mov rax, qword [msg_len]
	mov qword [msg+56], rax

	push msg
	call strLen_alt
	dec rax

	; TODO: Handle the new message in 64-byte pieces. Will retrofit it later.
	; START

	mov rcx, 16
	initWLoop:
		dec rcx
		mov dword [w+rcx*4], 0x00000000
		cmp rcx, 0
		jg initWLoop

	; TODO: Does this work?

	; END
	
	; Exit the program.
	mov rax, 1
	mov rbx, 0
	int 0x80


; ==== HELPER FUNCTIONS ====

swapEndian:
	mov rsi, [rsp+8]				; rsi = address of variable to swap endianness
	xor rax, rax					; rax = counter
	mov rcx, [rsp+16]				; rcx = size - rax
	dec rcx
	xor edx, edx					; dl = left byte | dh = right byte
	swapLoop_1:
		mov dl, byte [rsi+rax]
		mov dh, byte [rsi+rcx]
		mov byte [rsi+rax], dh
		mov byte [rsi+rcx], dl
		inc rax
		dec rcx
		cmp rcx, 0
		jne swapLoop_1
	ret


strLen_alt:						; arg - string to count
	mov rbx, [rsp+8]				; rbx = string to count
	xor rax, rax					; rax = counter
	xor rdx, rdx					; rdx = current char
	countLoop_2:
		mov dl, byte [rbx + rax]
		inc rax
		cmp rdx, 0xFF
		jne countLoop_2
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

; Gets the length of a string, INCLUDING the null terminator.
; Returns:
;	rax - string length
strLen:							; arg - string to count
	mov rbx, [rsp+8]				; rbx = string to count
	xor rax, rax					; rax = counter
	xor rdx, rdx					; rdx = current char
	countLoop_1:
		mov dl, byte [rbx + rax]
		inc rax
		cmp rdx, 0x00
		jne countLoop_1
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

; Copies one string to another, starting from the beginning. Includes the null terminator.
copyStr:						; args - source string | destination string
	mov rax, [rsp+8]				; rax = address of destination string
	mov rbx, [rsp+16]				; rbx = address of source string
	xor rdx, rdx					; rdx = current char
	xor rcx, rcx					; rcx = current char index
	copyLoop_1:
		mov dl, byte [rbx + rcx]
		mov byte [rax + rcx], dl
		inc rcx
		cmp rdx, 0x00
		jne copyLoop_1
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret
