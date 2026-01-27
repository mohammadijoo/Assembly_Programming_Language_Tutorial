BITS 64
default rel

global _start

section .data
align 8
g_counter dq 0
g_limit   dq 3

msg1 db "bump_counter(): counter updated", 10
msg1_len equ $-msg1
msg2 db "counter reached limit (>= g_limit)", 10
msg2_len equ $-msg2

section .text
_start:
    ; Demonstrate a writable global variable in .data
    call bump_counter

    lea rdi, [msg1]
    mov esi, msg1_len
    call write_str

    test eax, eax
    jz .done

    lea rdi, [msg2]
    mov esi, msg2_len
    call write_str

.done:
    mov eax, 60         ; sys_exit
    xor edi, edi
    syscall

; bump_counter():
;   Increments global g_counter and stores it back.
;   Returns EAX=1 if g_counter >= g_limit, else EAX=0.
bump_counter:
    mov rax, [g_counter]
    inc rax
    mov [g_counter], rax

    cmp rax, [g_limit]
    setae al
    movzx eax, al
    ret

; write_str(rdi=ptr, esi=len):
;   Writes exactly len bytes to STDOUT (fd=1).
write_str:
    mov edx, esi         ; rdx = len
    mov rsi, rdi         ; rsi = buf
    mov edi, 1           ; fd = 1
    mov eax, 1           ; sys_write
    syscall
    ret
