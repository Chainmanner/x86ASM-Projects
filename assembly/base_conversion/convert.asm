; To compile:
;	nasm -f elf64 convert.asm
;	ld -o convert convert.asm

section .data
	prompt_number:			db "Enter a number (4 digits max, base 10): ", 0
	prompt_number_len:		equ $ - prompt_number

	prompt_newbase:			db "Enter the base to convert this to (2 digits max, < 35): ", 0
	prompt_newbase_len:		equ $ - prompt_newbase

	response_converted1:		db "Number in base "
	response_converted1_len:	equ $ - response_converted1
	response_converted2:		db " : ", 0
	response_converted2_len:	equ $ - response_converted2
	
	newline:			db 0xA

section .bss
	input_number_str:	resb 4
	input_base_str:		resb 2
	input_number:		resb 2
	input_base:		resb 2
	output_temp:		resb 16
	output_number_str:	resb 16

section .text
global _start

_start:
	; Initialize the above uninitialized values.
	mov word [input_number], 0
	mov word [input_base], 0
	
	; Prompt for the input number.
	mov eax, 4
	mov ebx, 1
	mov ecx, prompt_number
	mov edx, prompt_number_len
	int 0x80
	mov eax, 3
	mov ebx, 1
	mov ecx, input_number_str
	mov edx, 4					; sizeof(input_number_str) == 4
	int 0x80

	; Prompt for the base to convert the number to.
	mov eax, 4
	mov ebx, 1
	mov ecx, prompt_newbase
	mov edx, prompt_newbase_len
	int 0x80
	mov eax, 3
	mov ebx, 1
	mov ecx, input_base_str
	mov edx, 2					; sizeof(input_base_str) == 2
	int 0x80

	; Convert the input strings to actual numbers. This one converts the input number to a string.
	xor rbx, rbx					; rbx = current digit multiplier
	xor rcx, rcx					; rcx = current char pos
	xor rdx, rdx
	mov dl, 3					; dl = length
	input_loop1:
		xor rax, rax
		mov al, byte [input_number_str + rdx]
		dec rdx
		cmp al, 0x30				; Check if the current character is under 0x30 - digit 0.
		jl input_loop1
		cmp al, 0x39				; Check if the current character is greater than 0x39 - digit 9.
		jg input_loop1
	
		sub al, 0x30
		push rdx				; Save the value of rdx by pushing it onto the stack. We'll need it for something else.
		xor dh, dh				; dh = times multiplied by 10
		input_loop2:				; Repeatedly multiply al by 10, depending on rbx.
			cmp dh, bl			; bl = rbx last byte
			je input_end2
			imul rax, 0xA
			inc dh
			jmp input_loop2
		input_end2:
		add word [input_number], ax
		pop rdx					; Restore rdx.
		inc rbx
		cmp rdx, -1
		jne input_loop1
	input_end1:
	
	; Same as the above code, but this time we're converting the base.
	xor rbx, rbx					; rbx = current digit multiplier
	xor rcx, rcx					; rcx = current char pos
	xor rdx, rdx
	mov dl, 1					; dl = length
	base_loop1:
		xor rax, rax
		mov al, byte [input_base_str + rdx]
		cmp al, 0xA
		je base_removeNL
		jmp base_removeNL_end
		base_removeNL:				; Remove the newline if present, since we're printing this string out again.
			mov byte [input_base_str + rdx], 0x0
		base_removeNL_end:
		
		dec rdx
		cmp al, 0x30				; Check if the current character is under 0x30 - digit 0.
		jl base_loop1
		cmp al, 0x39				; Check if the current character is greater than 0x39 - digit 9.
		jg base_loop1
	
		sub al, 0x30
		push rdx				; Save the value of rdx by pushing it onto the stack. We'll need it for something else.
		xor dh, dh				; dh = times multiplied by 10
		base_loop2:				; Repeatedly multiply al by 10, depending on rbx.
			cmp dh, bl			; bl = rbx last byte
			je base_end2
			imul rax, 0xA
			inc dh
			jmp base_loop2
		base_end2:
		add word [input_base], ax
		pop rdx					; Restore rdx.
		inc rbx
		cmp rdx, -1
		jne base_loop1
	base_end1:

	; Convert the input number's base.
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	mov bx, word [input_base]
	mov ax, word [input_number]
	xor r8, r8					; r8 = current digit
	convert_loop1:
		xor rdx, rdx
		cmp word [input_base], 0
		je convert_loop1_endpt			; To avoid division by zero.
		idiv word [input_base]			; result in RAX, remainder in RDX
		add dl, 0x30
		cmp dl, 0x39
		jg if_1
		jng else_1
		if_1:
			add dl, 0x7
		else_1:
		mov byte [output_temp + r8], dl
		inc r8
		cmp rax, 0
		jne convert_loop1
	convert_loop1_endpt:
	
	; Flip the output string, since the system is little-endian and I'm not sure how to get the number of digits from a number.
	xor rcx, rcx
	flip_loop1:
		xor rdx, rdx
		dec r8
		mov dl, byte [output_temp + r8]
		mov byte [output_number_str + rcx], dl
		inc rcx
		cmp r8, 0
		jne flip_loop1
	flip_loop1_endpt:

	; Print out the final result.
	mov eax, 4
	mov ebx, 1
	mov ecx, response_converted1
	mov edx, response_converted1_len
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, input_base_str
	mov edx, 2
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, response_converted2
	mov edx, response_converted2_len
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, output_number_str
	mov edx, 16
	int 0x80
	mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	; Exit the program.
	mov eax, 1
	mov ebx, 0
	int 0x80
