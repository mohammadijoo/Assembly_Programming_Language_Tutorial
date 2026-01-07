; Chapter 3 - Lesson 2 (Example 7)
; "Structured variables" with NASM struc/istruc (record-like layout)

BITS 64
default rel

struc Point32
    .x  resd 1
    .y  resd 1
endstruc

section .data
p:  istruc Point32
        at Point32.x, dd 10
        at Point32.y, dd -20
    iend

result      dd 0

msg         db "Computed (x*x + y*y) into [result].", 10
msg_len     equ $ - msg

section .text
global _start

_start:
    mov     eax, dword [p + Point32.x]
    imul    eax, eax                    ; x*x

    mov     ecx, dword [p + Point32.y]
    imul    ecx, ecx                    ; y*y

    add     eax, ecx
    mov     dword [result], eax

    ; print message
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [msg]
    mov     edx, msg_len
    syscall

    mov     eax, 60
    xor     edi, edi
    syscall
