; Chapter3_Lesson1_Ex5.asm
; Lesson goal: Indirection levels (value, pointer, pointer-to-pointer).
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex5.asm -o ex5.o
;   ld ex5.o -o ex5
; Run:
;   ./ex5

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
intro db "Pointer indirection demo:", 10, 0
m0 db "  secret_value = 0x", 0
m1 db "  ptr_to_secret (address) = 0x", 0
m2 db "  *ptr_to_secret (value) = 0x", 0
m3 db "  ptr_to_ptr (address) = 0x", 0
m4 db "  **ptr_to_ptr (value) = 0x", 0

section .data
align 8
secret_value dq 0xdeadbeefcafebabe
ptr_to_secret dq secret_value
ptr_to_ptr dq ptr_to_secret

section .text
global _start
_start:
    lea rdi, [intro]
    call write_z

    mov rax, [secret_value]
    lea rdi, [m0]
    call write_str_and_hex64

    ; ptr_to_secret holds an address.
    mov rax, [ptr_to_secret]
    lea rdi, [m1]
    call write_str_and_hex64

    ; Dereference once: load the qword at that address.
    mov rbx, [ptr_to_secret]
    mov rax, [rbx]
    lea rdi, [m2]
    call write_str_and_hex64

    ; ptr_to_ptr holds address of ptr_to_secret.
    mov rax, [ptr_to_ptr]
    lea rdi, [m3]
    call write_str_and_hex64

    ; Dereference twice:
    mov rbx, [ptr_to_ptr]    ; rbx = &ptr_to_secret
    mov rbx, [rbx]           ; rbx = ptr_to_secret = &secret_value
    mov rax, [rbx]           ; rax = secret_value
    lea rdi, [m4]
    call write_str_and_hex64

    sys_exit 0
