; Chapter 5 - Lesson 7 (Example 2)
; Standalone demo that calls switch_dense_abs and prints single-digit results.
; Demonstrates:
;   - external symbol call
;   - simple loop
;   - syscall write/exit
; NOTE: results are mapped to '0'..'9' by (result mod 10) for display simplicity.
; Build+Run:
;   nasm -f elf64 Chapter5_Lesson7_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2

default rel
bits 64

section .text
global _start

extern switch_dense_abs

_start:
    ; test values: -1,0,1,2,3,4,5,6
    lea rbx, [tests]
    mov ecx, 8

.loop:
    mov edi, dword [rbx]
    call switch_dense_abs          ; EAX = result

    ; make a printable digit: abs(result) mod 10
    mov edx, eax
    sar edx, 31                    ; sign mask (all 1s if negative)
    xor eax, edx
    sub eax, edx                   ; eax = abs(eax)

    xor edx, edx
    mov esi, 10
    div esi                        ; EDX = abs(result) mod 10

    add dl, '0'
    mov byte [buf], dl
    mov byte [buf+1], 10           ; '\n'

    ; write(1, buf, 2)
    mov eax, 1                     ; SYS_write
    mov edi, 1                     ; fd=stdout
    lea rsi, [buf]
    mov edx, 2
    syscall

    add rbx, 4
    loop .loop

    ; exit(0)
    mov eax, 60                    ; SYS_exit
    xor edi, edi
    syscall

section .rodata
tests:  dd -1, 0, 1, 2, 3, 4, 5, 6

section .bss
buf:    resb 2

; Bring Example 1's function into this TU by including its source.
; In real projects, you'd link object files instead.
%include "Chapter5_Lesson7_Ex1.asm"
