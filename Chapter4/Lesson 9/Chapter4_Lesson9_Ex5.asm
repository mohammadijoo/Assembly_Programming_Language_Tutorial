; Chapter4_Lesson9_Ex5.asm
; Partial-register hazard vs widening load idioms (byte case).

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
u8 db 0x80                   ; 128

SECTION .text
_start:
    mov rax, 0x1122334455667788

    ; "Narrow" load: writes only AL, leaving upper bits unchanged.
    mov al, [u8]              ; RAX now 0x11223344556677xx (xx=0x80)

    ; If you then use EAX as if it were 0..255, you must clean it:
    movzx eax, al             ; EAX=128, and RAX=128 because a 32-bit write clears upper 32 bits.

    ; Preferred: do it in one step.
    movzx eax, byte [u8]      ; EAX=128, RAX=128 (clean widening load)

    mov eax, 60
    xor edi, edi
    syscall
