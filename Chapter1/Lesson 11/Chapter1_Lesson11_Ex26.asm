; size_t my_strlen(const char* s)
; RDI = s, return RAX
global my_strlen_sysv
my_strlen_sysv:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je  .done
    inc rax
    jmp .loop
.done:
    ret
