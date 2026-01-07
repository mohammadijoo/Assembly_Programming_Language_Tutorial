; Chapter2_Lesson9_Ex3.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

default rel
global _start

section .data
msg     db "Hello", 10
msg_len equ $ - msg

section .text
_start:
    ; MOV loads/stores data. Address-of is NOT what MOV does by default.
    ; - mov al, [msg]  loads the first byte at msg ('H' = 0x48)
    ; - lea rbx, [msg] computes the address of msg without reading memory
    mov al, [msg]
    lea rbx, [msg]

    ; mov r64, imm64 can encode a full 64-bit constant (NASM chooses the right form).
    mov r10, 0x0123456789ABCDEF

    ; For many constants, the CPU form is "mov r/m64, imm32" (sign-extended).
    mov r11, 0x7FFFFFFF

    ; Exit status = 'H' (72).
    movzx edi, al
    mov eax, 60
    syscall
