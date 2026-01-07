; Chapter 2 - Lesson 10 - Example 2
; MOV width effects (partial registers), and x86-64 "mov into 32-bit reg zero-extends"
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex2.asm -o ex2.o && ld ex2.o -o ex2 && ./ex2 ; echo $?

global _start
section .text
_start:
    ; Set RAX = 0xFFFFFFFFFFFFFFFF
    mov rax, -1

    ; mov ax, imm16 overwrites only AX, leaving upper 48 bits intact
    mov ax, 0x1234
    ; Now RAX = 0xFFFFFFFFFFFF1234

    ; mov eax, imm32 overwrites EAX and *zero-extends* into RAX
    mov eax, 0x89ABCDEF
    ; Now RAX = 0x0000000089ABCDEF

    ; Verify the zero-extension property without printing:
    ; If upper 32 bits are zero, then (RAX >> 32) == 0
    mov rbx, rax
    shr rbx, 32
    cmp rbx, 0
    jne .fail

    ; Also demonstrate that mov al overwrites only low 8 bits
    mov rax, 0x1122334455667788
    mov al, 0x99
    ; RAX becomes 0x1122334455667799

    ; Return 0 on success
    xor edi, edi
    mov eax, 60
    syscall

.fail:
    mov edi, 1
    mov eax, 60
    syscall
