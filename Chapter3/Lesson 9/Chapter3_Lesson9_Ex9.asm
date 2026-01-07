; Chapter 3 - Lesson 9
; Ex9: Width-changing side effects in x86-64:
;   - Writing EAX zero-extends into RAX
;   - Writing AX/AL does NOT clear upper bits

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr: db "Partial register behavior (x86-64):",10,0
m1:  db "Initial RAX:                 ",0
m2:  db "After MOV EAX, 0x99AABBCC:   ",0
m3:  db "Reset RAX then MOV AX, 0x1234:",10,0
m4:  db "Initial RAX:                 ",0
m5:  db "After MOV AX, 0x1234:        ",0

section .text
_start:
    PRINTZ hdr

    mov rax, 0x1122334455667788
    PRINTZ m1
    call print_hex64_nl

    mov eax, 0x99AABBCC          ; zero-extends into RAX
    PRINTZ m2
    call print_hex64_nl

    PRINTZ m3
    mov rax, 0x1122334455667788
    PRINTZ m4
    call print_hex64_nl

    mov ax, 0x1234               ; upper 48 bits unchanged
    PRINTZ m5
    call print_hex64_nl

    jmp exit0
