BITS 64
default rel

global _start

section .data
s_ok db "18446744073709551615", 0     ; max u64
s_bad db "18446744073709551616", 0    ; overflow by 1
msg db "Exercise Solution: parse_u64 with overflow detection (no globals)", 10
msg_len equ $-msg

section .text
_start:
    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    ; parse ok string
    lea rdi, [s_ok]
    sub rsp, 16
    lea rsi, [rsp]         ; out value
    call parse_u64
    add rsp, 16

    ; ignore output; exit(0) if ok parse succeeded
    mov eax, 60
    xor edi, edi
    syscall

; parse_u64(str=rdi, out=rsi) -> eax=1 success, eax=0 failure/overflow
; No leading '+' or '-' supported. Stops on '\0'. Fails on non-digit.
parse_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; locals:
    ; [rbp-8]  = acc (u64)
    ; [rbp-16] = limit_q (u64) = UINT64_MAX / 10
    ; [rbp-24] = limit_r (u64) = UINT64_MAX % 10
    mov qword [rbp-8], 0
    mov rax, -1
    mov rcx, 10
    xor edx, edx
    div rcx                ; rax=UINT64_MAX/10, rdx=remainder
    mov [rbp-16], rax
    mov [rbp-24], rdx

.loop:
    mov al, [rdi]
    test al, al
    jz .done_ok

    cmp al, '0'
    jb .fail
    cmp al, '9'
    ja .fail

    ; digit = al - '0'
    movzx r8d, al
    sub r8d, '0'

    ; overflow check:
    ; if acc > limit_q OR (acc == limit_q AND digit > limit_r) -> fail
    mov rax, [rbp-8]
    mov r9, [rbp-16]
    cmp rax, r9
    ja .fail
    jne .safe
    mov r10, [rbp-24]
    cmp r8, r10
    ja .fail

.safe:
    ; acc = acc*10 + digit
    mov rcx, 10
    imul rax, rcx
    add rax, r8
    mov [rbp-8], rax

    inc rdi
    jmp .loop

.done_ok:
    mov rax, [rbp-8]
    mov [rsi], rax
    mov eax, 1
    leave
    ret

.fail:
    xor eax, eax
    leave
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
