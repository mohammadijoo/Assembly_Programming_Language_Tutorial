; ex2_strlen_runtime.asm
BITS 64

%define SYS_write 1
%define SYS_exit  60
%define STDOUT_FD 1

section .data
    msg db "Runtime strlen in assembly", 10, 0

section .text
global _start

; strlen(rsi=ptr) -> rax=len (bytes before 0)
strlen:
    xor eax, eax
.scan:
    cmp byte [rsi + rax], 0
    je .done
    inc eax
    jmp .scan
.done:
    ret

_start:
    lea rsi, [rel msg]
    call strlen              ; rax = length (not counting trailing 0)

    ; write(STDOUT, msg, len)
    mov edx, eax             ; len into edx (zero-extends)
    mov eax, SYS_write
    mov edi, STDOUT_FD
    lea rsi, [rel msg]
    syscall

    ; exit(0)
    mov eax, SYS_exit
    xor edi, edi
    syscall
