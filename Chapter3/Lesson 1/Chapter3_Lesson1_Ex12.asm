; Chapter3_Lesson1_Ex12.asm
; Programming Exercise 3 (solution):
; Decode signed 24-bit little-endian integers from memory and compute a 64-bit sum.
; Each element occupies 3 bytes: b0 (LSB), b1, b2 (MSB; sign bit is bit 23).
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex12.asm -o ex12.o
;   ld ex12.o -o ex12
; Run:
;   ./ex12

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
intro db "Exercise 3 solution: sum of signed 24-bit integers (LE)", 10, 0
m_sum db "Sum = 0x", 0

section .data
; Values (in decimal) for reference:
;  0x000001 = 1
;  0x7FFFFF =  8388607
;  0x800000 = -8388608 (two's complement 24-bit)
;  0xFFFFFE = -2
;  0x000010 = 16
packed24:
    db 0x01,0x00,0x00
    db 0xFF,0xFF,0x7F
    db 0x00,0x00,0x80
    db 0xFE,0xFF,0xFF
    db 0x10,0x00,0x00
packed24_end:

section .text
global _start

; decode_s24_le:
;   RSI points to 3 bytes.
;   Returns EAX = sign-extended 32-bit value.
decode_s24_le:
    ; Load 24 bits into EAX without reading beyond 3 bytes.
    movzx eax, byte [rsi]         ; b0
    movzx edx, byte [rsi + 1]     ; b1
    shl edx, 8
    or eax, edx
    movzx edx, byte [rsi + 2]     ; b2
    shl edx, 16
    or eax, edx                   ; EAX = 0x00bbccdd (24 bits)

    ; Sign-extend from bit 23: if set, fill high bits with 1s
    test eax, 0x00800000
    jz .ret
    or eax, 0xFF000000
.ret:
    ret

_start:
    lea rdi, [intro]
    call write_z

    xor rbx, rbx                  ; byte offset
    xor r12, r12                  ; sum in R12 (64-bit)
.loop:
    lea rsi, [packed24 + rbx]
    cmp rsi, packed24_end
    jae .done

    call decode_s24_le             ; EAX = signed 32-bit
    cdqe                           ; sign-extend EAX into RAX
    add r12, rax

    add rbx, 3
    jmp .loop

.done:
    mov rax, r12
    lea rdi, [m_sum]
    call write_str_and_hex64

    sys_exit 0
