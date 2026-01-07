; Chapter2_Lesson9_Ex7.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o

global _start
section .text
_start:
    mov rax, 0x1111
    mov rbx, 0x2222

    push rax

    ; Swap RBX with top-of-stack (memory operand).
    xchg rbx, [rsp]

    pop rcx                        ; RCX = 0x2222, RBX = 0x1111

    ; Exit status = (RBX + RCX) low byte = 0x33.
    lea eax, [ebx + ecx]
    and eax, 0xFF

    mov edi, eax
    mov eax, 60
    syscall
