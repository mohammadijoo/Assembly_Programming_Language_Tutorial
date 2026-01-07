; file: a.asm  (NASM, x86-64 SysV)
default rel

global a_entry
extern ext_func

section .text
a_entry:
    ; Call an external function (defined elsewhere).
    ; The assembler cannot know the final displacement yet.
    call ext_func

    ; Return a constant in EAX
    mov eax, 1234
    ret
