; Chapter 3 - Lesson 2 (Example 4)
; Size specifiers: byte/word/dword/qword and extension instructions

BITS 64
default rel

section .data
var8        db 0
var16       dw 0
var32       dd 0
var64       dq 0

msg         db "Wrote multi-size variables; inspect memory in a debugger.", 10
msg_len     equ $ - msg

section .text
global _start

_start:
    ; The following would be ambiguous in NASM (memory size unknown):
    ;   mov [var8], 1
    ; Correct usage requires an explicit size:
    mov     byte  [var8],  1
    mov     word  [var16], 0x0203
    mov     dword [var32], 0x04050607
    mov     qword [var64], 0x08090A0B0C0D0E0F

    ; Load with extension:
    movsx   eax, byte [var8]        ; sign-extend 8-bit -> 32-bit
    movzx   ecx, word [var16]       ; zero-extend 16-bit -> 32-bit
    add     eax, ecx
    mov     dword [var32], eax      ; store derived value

    ; print message
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [msg]
    mov     edx, msg_len
    syscall

    mov     eax, 60
    xor     edi, edi
    syscall
