; Chapter5_Lesson2_Ex1.asm
; Lesson 2 (Chapter 5): Implementing Loops (FOR, WHILE, DO-WHILE in Assembly)
; Topic demo: WHILE (pre-test) loop summing a byte array
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson2_Ex1.asm -o Chapter5_Lesson2_Ex1.o
;   ld -o Chapter5_Lesson2_Ex1 Chapter5_Lesson2_Ex1.o
;
; Run:
;   ./Chapter5_Lesson2_Ex1
;   echo $?
;
; Exit status = (sum(arr[i]) mod 256)

BITS 64
default rel

section .data
arr:     db 3, 5, 7, 11, 13, 17, 19, 23, 29, 31
arr_len  equ $-arr

section .text
global _start

_start:
    xor eax, eax              ; RAX = sum
    xor ecx, ecx              ; ECX = i
    lea rsi, [arr]            ; RSI = base pointer

.while_test:
    cmp ecx, arr_len          ; i < len ?
    jae .done                 ; if i >= len, exit loop
    movzx edx, byte [rsi+rcx] ; EDX = arr[i] (zero-extended)
    add eax, edx              ; sum += arr[i]
    inc ecx                   ; i++
    jmp .while_test

.done:
    and eax, 255              ; map sum to an 8-bit process exit code
    mov edi, eax              ; rdi = status
    mov eax, 60               ; SYS_exit
    syscall
