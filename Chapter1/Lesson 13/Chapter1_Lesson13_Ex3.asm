; src/print_nasm.asm (NASM)
global print_str

%include "syscalls_linux_x86_64.inc"

section .text
; void print_str(const char* s)
; Contract: s is a null-terminated string in user memory
print_str:
    ; Compute length (strlen) manually
    push rbx
    mov rbx, rdi            ; rbx = s (cursor)
.len_loop:
    cmp byte [rbx], 0
    je .len_done
    inc rbx
    jmp .len_loop
.len_done:
    ; rbx points at terminator; length = rbx - rdi
    mov rdx, rbx
    sub rdx, rdi

    ; write(1, s, len)
    mov eax, SYS_write
    mov edi, 1              ; fd = stdout
    mov rsi, rdi            ; buf = s
    syscall

    pop rbx
    ret
