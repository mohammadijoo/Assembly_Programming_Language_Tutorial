; Demonstrates: generating a constant table at assembly time and iterating over it

BITS 64
global _start

SYS_exit equ 60

section .data
; table[i] = i for i=0..15
table:      %assign i 0
            %rep 16
            db i
            %assign i i+1
            %endrep
table_len   equ $ - table

; NOTE: %rep/%assign are NASM preprocessor features. This file previews them briefly.
; If your course defers preprocessor details, you can instead write:
; table: times 16 db 0

section .text
_start:
    ; Sum the table in AL (mod 256), return it as exit code
    xor     eax, eax
    xor     ecx, ecx
.loop:
    add     al, byte [rel table + rcx]
    inc     ecx
    cmp     ecx, table_len
    jb      .loop

    mov     edi, eax
    mov     eax, SYS_exit
    syscall
