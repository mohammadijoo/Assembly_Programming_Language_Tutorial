BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
msg1  db "Hex digit encoding demo (nibble -> ASCII)",10,0
msg2  db "For each value 0..15: show table lookup and XLAT result",10,0
arrow db " -> ",0

section .bss
out2  resb 2

section .text
global _start

; Method 1: table lookup with explicit addressing.
nibble_to_hex_table:
    and al, 0x0F
    movzx eax, al
    mov al, [hex_digits+rax]
    ret

; Method 2: XLATB instruction (legacy, but instructive).
;   AL is the index, RBX is the table base.
nibble_to_hex_xlat:
    and al, 0x0F
    lea rbx, [hex_digits]
    xlatb
    ret

_start:
    mov rdi, STDOUT
    lea rsi, [msg1]
    call print_cstr
    mov rdi, STDOUT
    lea rsi, [msg2]
    call print_cstr

    xor ecx, ecx
.loop:
    mov rdi, rcx
    call print_dec_u64

    mov rdi, STDOUT
    lea rsi, [arrow]
    call print_cstr

    mov al, cl
    call nibble_to_hex_table
    mov [out2], al

    mov al, cl
    call nibble_to_hex_xlat
    mov [out2+1], al

    mov rdi, STDOUT
    lea rsi, [out2]
    mov rdx, 2
    call write_buf

    call print_nl

    inc ecx
    cmp ecx, 16
    jb .loop

    mov eax, SYS_exit
    xor edi, edi
    syscall
