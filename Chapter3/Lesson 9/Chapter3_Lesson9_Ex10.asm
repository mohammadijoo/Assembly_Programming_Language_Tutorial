; Chapter 3 - Lesson 9
; Ex10: Multiplication widening + overflow signals (IMUL/MUL and OF/CF meaning)
;
; For 32-bit forms:
;   IMUL r/m32   => signed product in EDX:EAX, OF=CF=1 if it doesn't fit in 32-bit signed
;   MUL  r/m32   => unsigned product in EDX:EAX, OF=CF=1 if EDX != 0 (upper half non-zero)

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:     db "IMUL/MUL overflow behavior:",10,0

p1:      db "Case 1 (signed): 50000 * 50000 using 32-bit IMUL (EDX:EAX)",10,0
lbl_prod:db "  Product (EDX:EAX as uint64 hex): ",0
lbl_of:  db "  OF (also CF) from IMUL:          ",0

p2:      db 10,"Case 2 (unsigned): 0xFFFFFFFF * 2 using 32-bit MUL (EDX:EAX)",10,0
lbl_cf:  db "  CF (also OF) from MUL:           ",0

section .text
_start:
    PRINTZ hdr

    ; ---- Case 1: signed IMUL ----
    PRINTZ p1
    mov eax, 50000
    mov ecx, 50000
    imul ecx                      ; EDX:EAX = EAX * ECX (signed)
    seto bl                       ; OF==CF for one-operand IMUL

    ; Compose uint64 = (uint64)(uint32)EDX<<32 | (uint32)EAX
    mov rax, 0
    mov eax, eax                  ; RAX = low32
    mov r9d, edx                  ; R9D = high32
    mov r10, r9
    shl r10, 32
    or  rax, r10

    PRINTZ lbl_prod
    call print_hex64_nl

    PRINTZ lbl_of
    movzx rax, bl
    call print_u64_nl

    ; ---- Case 2: unsigned MUL ----
    PRINTZ p2
    mov eax, 0xFFFFFFFF
    mov ecx, 2
    mul ecx                       ; EDX:EAX = EAX * ECX (unsigned)
    setc bl                       ; CF==OF for MUL: 1 if upper half non-zero

    mov rax, 0
    mov eax, eax
    mov r9d, edx
    mov r10, r9
    shl r10, 32
    or  rax, r10

    PRINTZ lbl_prod
    call print_hex64_nl

    PRINTZ lbl_cf
    movzx rax, bl
    call print_u64_nl

    jmp exit0
