\
; Chapter2_Lesson6_Ex2.asm
; NASM: producing a relocatable object with exported symbols and multiple sections.
; This file is intended to be linked into a larger program.
;
; Build:
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex2.asm -o ex2.o
; Inspect:
;   readelf -S ex2.o
;   readelf -s ex2.o

BITS 64
default rel

section .text
global add_u64
global addr_of_table

; uint64_t add_u64(uint64_t a, uint64_t b)  (SysV AMD64 ABI)
add_u64:
    lea rax, [rdi + rsi]
    ret

; uint64_t addr_of_table(void)
; Returns the address of a constant table to show that the assembler emits
; relocation info (RIP-relative relocation in ELF64).
addr_of_table:
    lea rax, [table64]       ; relocatable reference (RIP-relative)
    ret

section .rodata align=16
global table64
table64:
    dq 0x1122334455667788
    dq 0x99AABBCCDDEEFF00
    dq 0x0123456789ABCDEF
    dq 0x0F0E0D0C0B0A0908
