BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
hdr db "Byte dump (hex) of a 16-byte data block:",10,0
spc db " ",0

data_block db 0xDE,0xAD,0xBE,0xEF, 1,2,3,4, 0x10,0x20,0x30,0x40, 0x7F,0x80,0xFF,0x00
data_len   equ $-data_block

section .bss
pair resb 2

section .text
global _start

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    xor rcx, rcx
.loop:
    mov dil, [data_block+rcx]
    lea rsi, [pair]
    call hexbyte_to_ascii

    mov rdi, STDOUT
    lea rsi, [pair]
    mov rdx, 2
    call write_buf

    mov rdi, STDOUT
    lea rsi, [spc]
    call print_cstr

    inc rcx
    cmp rcx, data_len
    jb .loop

    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall
