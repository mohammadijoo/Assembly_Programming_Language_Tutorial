; Chapter 3 - Lesson 11 - Example 5
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5
;
; Purpose:
;   A "header-style" assembly module containing reusable alignment macros and
;   an alignment-dispatch routine for SIMD loads.
;
;   In larger projects you would typically put these macros in a file and:
;       %include "align_utils.asm"
;   then assemble multiple .asm files together.

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

; -----------------------------------------
; "Header" region: macros + helper routine signatures
; -----------------------------------------

; ALIGN_UP_REG reg, align_pow2
; reg := smallest multiple of align_pow2 that is >= reg
%macro ALIGN_UP_REG 2
    lea %1, [%1 + (%2 - 1)]
    and %1, -%2
%endmacro

; IS_ALIGNED_REG reg, align_pow2
; Sets ZF=1 if aligned, ZF=0 if not aligned
%macro IS_ALIGNED_REG 2
    test %1, (%2 - 1)
%endmacro

; load_xmm16_auto:
;   input: rdi = pointer
;   output: xmm0 = 16 bytes from [rdi], using MOVDQA if aligned, else MOVDQU
;   clobbers: rax
global load_xmm16_auto
load_xmm16_auto:
    mov rax, rdi
    and rax, 15
    jnz .unaligned
.aligned:
    movdqa xmm0, [rdi]
    ret
.unaligned:
    movdqu xmm0, [rdi]
    ret

; -----------------------------------------
; Demo program
; -----------------------------------------
section .data
    msg0 db "load_xmm16_auto chooses MOVDQA if addr mod 16 == 0",10,0
    msg1 db "  aligned ptr remainder = ",0
    msg2 db "  unaligned ptr remainder = ",0

hex_lut db "0123456789ABCDEF"

    align 16
bufA: times 32 db 0xAA
bufB: times 32 db 0xBB

section .bss
    hexbuf resb 19

section .text
global _start

write_buf:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

print_z:
    xor ecx, ecx
.count:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .count
.done:
    mov rdx, rcx
    call write_buf
    ret

print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'
    mov rbx, rax
    mov rcx, 16
    lea rdi, [hexbuf + 2 + 15]
.hex_loop:
    mov rdx, rbx
    and rdx, 0xF
    mov dl, [hex_lut + rdx]
    mov [rdi], dl
    shr rbx, 4
    dec rdi
    dec rcx
    jnz .hex_loop
    mov byte [hexbuf + 18], 10
    lea rsi, [hexbuf]
    mov edx, 19
    call write_buf
    ret

print_labeled_hex:
    call print_z
    call print_hex64
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; aligned pointer
    lea rdi, [bufA]
    call load_xmm16_auto

    lea rsi, [msg1]
    mov rax, rdi
    and rax, 15
    call print_labeled_hex

    ; unaligned pointer
    lea rdi, [bufB + 1]
    call load_xmm16_auto

    lea rsi, [msg2]
    mov rax, rdi
    and rax, 15
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall
