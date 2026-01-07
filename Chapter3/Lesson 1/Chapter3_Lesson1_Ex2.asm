; Chapter3_Lesson1_Ex2.asm
; Lesson goal: See where "things live" by printing runtime addresses of labels.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex2.asm -o ex2.o
;   ld ex2.o -o ex2
; Run:
;   ./ex2

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
msg_intro    db "Addresses of representative labels:", 10, 0
msg_text     db "  .text  (_start) = 0x", 0
msg_rodata   db "  .rodata(msg_intro) = 0x", 0
msg_data     db "  .data  (numbers) = 0x", 0
msg_bss      db "  .bss   (scratch) = 0x", 0
msg_n1       db "  numbers[0] (qword) = 0x", 0

section .data
align 16
numbers dq 0x1122334455667788, 0x99aabbccddeeff00, 0x0123456789abcdef

section .bss
align 16
scratch resb 64

section .text
global _start
_start:
    lea rdi, [msg_intro]
    call write_z

    ; Print addresses using LEA (RIP-relative, PIE-friendly in concept).
    lea rdi, [msg_text]
    lea rax, [_start]
    call write_str_and_hex64

    lea rdi, [msg_rodata]
    lea rax, [msg_intro]
    call write_str_and_hex64

    lea rdi, [msg_data]
    lea rax, [numbers]
    call write_str_and_hex64

    lea rdi, [msg_bss]
    lea rax, [scratch]
    call write_str_and_hex64

    ; Demonstrate difference: address vs content.
    ; numbers holds data; [numbers] dereferences and loads the first qword value.
    lea rdi, [msg_n1]
    mov rax, [numbers]
    call write_str_and_hex64

    sys_exit 0
