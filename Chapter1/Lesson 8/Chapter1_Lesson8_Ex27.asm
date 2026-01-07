; file: sections_demo.asm
global _start

section .text.hot
_start:
    call fast_path
    jmp done

section .text.cold
error_path:
    ; cold code: rarely executed
    mov rax, 60
    mov rdi, 2
    syscall

section .text.hot
fast_path:
    ; pretend this is hot
    ret

section .text.hot
done:
    mov rax, 60
    xor rdi, rdi
    syscall
