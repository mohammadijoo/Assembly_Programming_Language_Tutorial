; Chapter 4 - Lesson 5 (Exercise Solution)
; File: Chapter4_Lesson5_Ex10.asm
; Task: 256-bit membership test using TEST on a packed bitset (values 0..255).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex10.asm -o ex10.o
;   ld ex10.o -o ex10

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
; bitset has 256 bits = 32 bytes. Bit i is stored at bit (i&7) in byte [i>>3].
bitset: times 32 db 0

; Test queries
q1: db 3
q2: db 5
q3: db 200
q4: db 201

msg_in:  db "member = 1 (present)", 10, 0
msg_out: db "member = 0 (absent)", 10, 0
msg_q:   db "query = ", 0

section .text
; void set_member(al=value 0..255)
set_member:
    movzx eax, al
    mov edx, eax
    shr eax, 3            ; byte index
    and edx, 7            ; bit position
    mov bl, 1
    mov cl, dl
    shl bl, cl
    or byte [rel bitset + rax], bl
    ret

; uint8 is_member(al=value 0..255) -> al in {0,1}
is_member:
    movzx eax, al
    mov edx, eax
    shr eax, 3            ; byte index
    and edx, 7            ; bit position
    mov bl, 1
    mov cl, dl
    shl bl, cl
    test byte [rel bitset + rax], bl
    setnz al
    ret

; Print query value in hex (low byte), then membership
print_query_and_answer:
    ; al = query
    push rax
    lea rsi, [rel msg_q]
    call print_cstr
    pop rax
    ; print as full hex64 for simplicity
    movzx eax, al
    call print_hex64

    ; membership
    call is_member
    test al, al
    jz .absent
.present:
    lea rsi, [rel msg_in]
    call print_cstr
    ret
.absent:
    lea rsi, [rel msg_out]
    call print_cstr
    ret

_start:
    ; Populate set: {3,5,200}
    mov al, 3
    call set_member
    mov al, 5
    call set_member
    mov al, 200
    call set_member

    mov al, [rel q1]
    call print_query_and_answer
    mov al, [rel q2]
    call print_query_and_answer
    mov al, [rel q3]
    call print_query_and_answer
    mov al, [rel q4]
    call print_query_and_answer

    SYS_EXIT 0
