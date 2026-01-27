; Chapter5_Lesson2_Ex8.asm
; Topic demo: NASM macros as "loop templates" (similar to header/include patterns)
;
; In larger projects you'd typically put macros into an include file:
;   %include "loop_macros.inc"
; Here we keep everything in one .asm for portability.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex8.asm -o Chapter5_Lesson2_Ex8.o
;   ld -o Chapter5_Lesson2_Ex8 Chapter5_Lesson2_Ex8.o
;
; Program fills a buffer with 0..15 using a macro-defined loop.
; Exit status = last written byte (should be 15).

BITS 64
default rel

%macro FILL_INC 2
    ; FILL_INC dest_ptr, count
    mov rdi, %1
    mov ecx, %2
    xor eax, eax
%%loop:
    mov [rdi], al
    inc al
    inc rdi
    dec ecx
    jnz %%loop
%endmacro

section .bss
buf: resb 16

section .text
global _start

_start:
    lea rbx, [buf]
    FILL_INC rbx, 16

    ; Return last byte as an exit status (buf[15])
    movzx edi, byte [buf+15]
    mov eax, 60
    syscall
