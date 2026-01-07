; Chapter4_Lesson9_Ex1.asm
; MOVZX/MOVSX: baseline forms (NASM, x86-64 Linux, SysV)
; Inspect registers in a debugger to confirm the comments.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
u8  db 0xFF          ; 255
s8  db -1            ; 0xFF interpreted as signed -> -1
u16 dw 0xFF00        ; 65280
s16 dw -256          ; 0xFF00 interpreted as signed -> -256

SECTION .text
_start:
    ; Zero-extension (unsigned widening)
    movzx eax, byte [u8]     ; EAX = 255, and in 64-bit mode RAX = 255
    movzx ecx, word [u16]    ; ECX = 65280

    ; Sign-extension (signed widening)
    movsx edx, byte [s8]     ; EDX = 0xFFFFFFFF (-1)
    movsx r8,  byte [s8]     ; R8  = 0xFFFFFFFFFFFFFFFF (-1)
    movsx r9d, word [s16]    ; R9D = 0xFFFFFF00 (-256)

    ; Notes:
    ; - MOVZX formally targets r16/r32. In x86-64, writing a 32-bit GPR clears the upper 32 bits.
    ; - MOVSX can target r16/r32 and, in 64-bit mode, r64 for byte/word sources.
    ; - There is no MOVSX from r/m32 to r64; use MOVSXD or CDQE for that case.

    mov eax, 60              ; sys_exit
    xor edi, edi             ; status = 0
    syscall
