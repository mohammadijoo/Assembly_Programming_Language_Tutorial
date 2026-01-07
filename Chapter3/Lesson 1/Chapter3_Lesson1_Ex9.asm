; Chapter3_Lesson1_Ex9.asm
; Lesson goal: "Struct-like" layout in memory using NASM struc/istruc.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex9.asm -o ex9.o
;   ld ex9.o -o ex9
; Run:
;   ./ex9

%include "Chapter3_Lesson1_Ex1.asm"
default rel

struc PERSON
    .age      resb 1
    .flags    resb 1
    .heightCm resw 1
    .id       resd 1
    .next     resq 1
endstruc

section .rodata
intro db "Struct-like layout demo (PERSON):", 10, 0
m_base db "  &p1 = 0x", 0
m_age  db "  p1.age (byte) = 0x", 0
m_id   db "  p1.id (dword) = 0x", 0
m_next db "  p1.next (qword ptr) = 0x", 0

section .data
align 8
p2:
    istruc PERSON
        at PERSON.age,      db 25
        at PERSON.flags,    db 0x5A
        at PERSON.heightCm, dw 180
        at PERSON.id,       dd 0x01020304
        at PERSON.next,     dq 0
    iend

p1:
    istruc PERSON
        at PERSON.age,      db 42
        at PERSON.flags,    db 0xA5
        at PERSON.heightCm, dw 175
        at PERSON.id,       dd 0x11223344
        at PERSON.next,     dq p2
    iend

section .text
global _start
_start:
    lea rdi, [intro]
    call write_z

    lea rax, [p1]
    lea rdi, [m_base]
    call write_str_and_hex64

    ; Load fields via base + offset
    movzx eax, byte [p1 + PERSON.age]
    lea rdi, [m_age]
    call write_str_and_hex64

    mov eax, dword [p1 + PERSON.id]
    ; print as 64-bit (zero-extended in RAX because EAX write)
    lea rdi, [m_id]
    call write_str_and_hex64

    mov rax, [p1 + PERSON.next]
    lea rdi, [m_next]
    call write_str_and_hex64

    sys_exit 0
