; Chapter4_Lesson9_Ex4.asm
; 32 -> 64 sign extension: MOVSXD vs "implicit" zero extension of 32-bit loads.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
x32 dd -1                    ; 0xFFFFFFFF in memory

SECTION .text
_start:
    ; Case A: plain 32-bit load into EAX
    mov eax, dword [x32]      ; EAX = 0xFFFFFFFF, but RAX becomes 0x00000000FFFFFFFF (zero-extended)

    ; Case B: signed 32->64 extension at load time
    movsxd rbx, dword [x32]   ; RBX = 0xFFFFFFFFFFFFFFFF (-1)

    ; Case C: sign-extend EAX after the load
    mov eax, dword [x32]      ; EAX = 0xFFFFFFFF again
    cdqe                      ; RAX = sign-extended EAX -> 0xFFFFFFFFFFFFFFFF

    mov eax, 60
    xor edi, edi
    syscall
