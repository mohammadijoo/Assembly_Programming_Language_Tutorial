; Chapter 3 - Lesson 9
; Ex7: Sign-extension instructions (CBW/CWD/CDQ/CQO) + their intended operand widths

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:  db "Sign extension instructions demo:",10,0

p1:   db "1) CBW/CWD on AL/AX (8->16, 16->32 via DX:AX)",10,0
p2:   db 10,"2) CDQ on EAX (32->64 via EDX:EAX) [note: CDQ writes EDX (32-bit)]",10,0
p3:   db 10,"3) CQO on RAX (64->128 via RDX:RAX)",10,0

lbl_ax: db "  After CBW (AX), as signed: ",0
lbl_dxax: db "  After CWD (DX:AX), DX in hex: ",0
lbl_eax: db "  EAX input (hex): ",0
lbl_edx: db "  After CDQ, EDX (printed as RDX hex, upper 32 bits are zeroed in x86-64): ",0
lbl_rdx: db "  After CQO, RDX (hex): ",0

section .text
_start:
    PRINTZ hdr

    ; ---- 1) CBW / CWD ----
    PRINTZ p1
    mov al, 0x80                 ; -128 as int8
    cbw                          ; sign-extend AL -> AX

    PRINTZ lbl_ax
    movsx rax, ax
    call print_i64_nl

    cwd                          ; sign-extend AX -> DX:AX (both 16-bit regs)
    PRINTZ lbl_dxax
    ; DX is 16-bit; move into RAX for printing
    movsx rax, dx
    call print_hex64_nl

    ; ---- 2) CDQ ----
    PRINTZ p2
    mov eax, 0x80000000          ; -2147483648 as int32
    PRINTZ lbl_eax
    mov rax, 0x0000000080000000
    call print_hex64_nl

    cdq                          ; sign-extend EAX into EDX:EAX (32-bit semantics)
    PRINTZ lbl_edx
    mov eax, edx                 ; move EDX into EAX (zero-extends to RAX)
    call print_hex64_nl

    ; ---- 3) CQO ----
    PRINTZ p3
    mov rax, -5
    cqo                          ; sign-extend RAX into RDX:RAX

    PRINTZ lbl_rdx
    mov rax, rdx
    call print_hex64_nl

    jmp exit0
