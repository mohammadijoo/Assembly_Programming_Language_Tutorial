; Chapter5_Lesson2_Ex6.asm
; Topic demo: REPNE SCASB as a hardware-assisted loop (memchr-like scan)
;
; Search a byte buffer for a target byte using REPNE SCASB.
; If found, exit status = index (0..255). If not found, exit status = 255.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex6.asm -o Chapter5_Lesson2_Ex6.o
;   ld -o Chapter5_Lesson2_Ex6 Chapter5_Lesson2_Ex6.o

BITS 64
default rel

section .data
buf:     db 0x10, 0x20, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99
buf_len  equ $-buf
target   equ 0x55

section .text
global _start

_start:
    cld
    lea rdi, [buf]       ; RDI = start
    mov rcx, buf_len     ; RCX = count
    mov al, target       ; AL = needle
    mov rbx, rcx         ; save original length

    repne scasb          ; while (RCX!=0 && *RDI!=AL) {RDI++; RCX--;}
    jne .not_found       ; ZF==0 => not found (exhausted RCX)

    ; found: RDI points one past the match, RCX has remaining count
    mov rax, rbx
    sub rax, rcx
    dec rax              ; index = len - RCX - 1

    and eax, 255
    mov edi, eax
    mov eax, 60
    syscall

.not_found:
    mov edi, 255
    mov eax, 60
    syscall
