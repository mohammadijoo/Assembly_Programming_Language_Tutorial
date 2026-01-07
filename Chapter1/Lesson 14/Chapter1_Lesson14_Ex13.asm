; NASM object layout essentials
global foo
extern bar

section .text
foo:
    call bar
    ret
