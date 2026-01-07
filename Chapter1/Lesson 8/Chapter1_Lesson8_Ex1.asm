; NASM syntax (x86-64, SysV ABI conceptually)
; file: hello_puts.asm

default rel

global main
extern puts

section .rodata
msg: db "Hello from assembly (puts)!", 0

section .text
main:
    ; rdi = pointer to C string
    lea rdi, [msg]
    xor eax, eax          ; SysV ABI: clear AL for variadic calls (puts is not variadic, but safe habit)
    call puts             ; undefined here: assembler emits relocation against symbol 'puts'
    xor eax, eax
    ret
