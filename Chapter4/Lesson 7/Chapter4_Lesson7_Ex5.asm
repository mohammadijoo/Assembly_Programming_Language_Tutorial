; Minimal NASM "header" (include file) implemented as .asm per course convention.
; Intended usage:  %include "Chapter4_Lesson7_Ex5.asm"
; Provides:
;   - SYS_WRITE fd, buf, len
;   - SYS_EXIT  code
;   - print_cstr: writes a zero-terminated string at RSI to stdout

%ifndef CH4_L7_SYSCALLS_GUARD
%define CH4_L7_SYSCALLS_GUARD 1

%macro SYS_WRITE 3
    mov eax, 1        ; __NR_write
    mov edi, %1       ; fd
    mov rsi, %2       ; buf
    mov edx, %3       ; len
    syscall
%endmacro

%macro SYS_EXIT 1
    mov eax, 60       ; __NR_exit
    mov edi, %1       ; status
    syscall
%endmacro

; rsi -> zero-terminated string, clobbers rax, rdi, rdx, rcx, r11
print_cstr:
    push rbx
    mov rbx, rsi

.len_loop:
    mov al, [rbx]
    test al, al
    jz .len_done
    inc rbx
    jmp .len_loop

.len_done:
    ; len = rbx - rsi
    mov rdx, rbx
    sub rdx, rsi
    mov eax, 1
    mov edi, 1
    syscall
    pop rbx
    ret

%endif
