; Chapter 5 - Lesson 8, Exercise Solution 4
; 2-bit saturating counter branch predictor simulator.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
outcomes db 1,1,1,0,0,0,1,1,0,1,0,0,1,1,1,1,0,0,1,0,1,0,1,0,0,0,0,1,1,1
N equ $-outcomes
mispreds dq 0
final_state db 0

section .text
_start:
    mov bl, 1
    xor r8d, r8d
    xor rsi, rsi
.loop:
    cmp rsi, N
    je  .done
    mov al, [outcomes + rsi]
    mov dl, bl
    cmp dl, 2
    setae dh
    xor dh, al
    and dh, 1
    movzx edx, dh
    add r8d, edx
    test al, al
    jz   .nt
.t:
    cmp bl, 3
    jae .next
    inc bl
    jmp .next
.nt:
    test bl, bl
    jz   .next
    dec bl
.next:
    inc rsi
    jmp .loop
.done:
    mov [mispreds], r8
    mov [final_state], bl
    mov eax, 60
    xor edi, edi
    syscall
