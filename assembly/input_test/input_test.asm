section .data
	prompt_input:		db "Enter some text: ", 0
	prompt_input_len:	equ $ - prompt_input
	response_input:		db "You have entered: ", 0
	response_input_len:	equ $ - response_input

section .bss
	input_text:	resb 256

section .text
global _start

_start:
	mov eax, 4
	mov ebx, 1
	mov ecx, prompt_input
	mov edx, prompt_input_len
	int 0x80

	; Read input.
	mov eax, 3
	mov ebx, 1
	mov ecx, input_text
	mov edx, 256
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, 0xA	; OxA = newline
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, response_input
	mov edx, response_input_len
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, input_text
	mov edx, 256
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, 0xA
	mov edx, 1
	int 0x80

	; ???
	;mov eax, 29
	;int 0x80

	mov eax, 1
	mov ebx, 0
	int 0x80
