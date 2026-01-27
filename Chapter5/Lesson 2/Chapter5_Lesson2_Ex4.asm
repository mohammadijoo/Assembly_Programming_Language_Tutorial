; Chapter5_Lesson2_Ex4.asm
; Topic demo: Pointer-based loop with countdown (common in optimized code)
;
; Find the maximum in an int32 array using a decrement-and-branch pattern.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex4.asm -o Chapter5_Lesson2_Ex4.o
;   ld -o Chapter5_Lesson2_Ex4 Chapter5_Lesson2_Ex4.o
;
; Exit status = (max mod 256)

BITS 64
default rel

section .data
arr: dd -10, 15, 3, 27, -5, 9, 27, 2
len equ ($-arr)/4

section .text
global _start

_start:
    mov ecx, len        ; ECX = remaining elements
    lea rsi, [arr]      ; RSI = pointer

    ; Precondition: len > 0
    mov eax, [rsi]      ; EAX = max = arr[0]
    add rsi, 4
    dec ecx
    jz .done_compute

.loop:
    mov edx, [rsi]
    cmp edx, eax
    jle .skip
    mov eax, edx
.skip:
    add rsi, 4
    dec ecx
    jnz .loop

.done_compute:
    and eax, 255
    mov edi, eax
    mov eax, 60         ; SYS_exit
    syscall
