; Chapter 3 - Lesson 2 (Example 2)
; Declaring arrays and updating a "variable" in memory (sum32)

BITS 64
default rel

section .data
arr         db 3, 1, 4, 1, 5, 9, 2, 6
arr_len     equ $ - arr

sum32       dd 0

msg         db "Sum computed and stored into [sum32].", 10
msg_len     equ $ - msg

section .text
global _start

_start:
    xor     eax, eax        ; EAX = running sum
    xor     ebx, ebx        ; RBX = index

.loop:
    movzx   ecx, byte [arr + rbx]   ; load arr[rbx] (0..255)
    add     eax, ecx
    inc     rbx
    cmp     rbx, arr_len
    jne     .loop

    mov     dword [sum32], eax      ; store result (explicit size)

    ; demonstrate reading back the variable (optional, for debugger inspection)
    mov     edx, dword [sum32]      ; EDX now holds the sum

    ; print message (we do not print the numeric value yet; see later lessons)
    mov     eax, 1                  ; SYS_write
    mov     edi, 1                  ; stdout
    lea     rsi, [msg]
    mov     edx, msg_len
    syscall

    mov     eax, 60                 ; SYS_exit
    xor     edi, edi
    syscall
