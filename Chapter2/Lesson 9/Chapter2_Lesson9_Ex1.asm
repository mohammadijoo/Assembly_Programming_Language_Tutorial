; Chapter2_Lesson9_Ex1.asm
; Build (Linux x86-64, NASM):
;   nasm -felf64 Chapter2_Lesson9_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; echo $?

global _start
section .text
_start:
    ; MOV: register <- immediate / register
    mov rax, 0x1122334455667788

    ; In x86-64, writing a 32-bit GPR zero-extends the upper 32 bits.
    mov eax, 0xAABBCCDD          ; RAX becomes 0x00000000AABBCCDD

    mov rcx, rax                 ; copy register -> register
    mov rdx, 12345               ; imm32 encoded, sign-extended to 64-bit by hardware

    ; Two related idioms:
    ; 1) mov r64, -1 uses an imm32 encoding (0xFFFFFFFF) sign-extended -> all-ones.
    mov rsi, -1                  ; RSI = 0xFFFFFFFFFFFFFFFF

    ; 2) mov r32, -1 sets the low 32 bits and zero-extends into the 64-bit register.
    mov edi, -1                  ; RDI = 0x00000000FFFFFFFF

    ; Return the low byte of RDI as the process exit status (255).
    mov eax, 60                  ; SYS_exit
    ; EDI already holds the status
    syscall
