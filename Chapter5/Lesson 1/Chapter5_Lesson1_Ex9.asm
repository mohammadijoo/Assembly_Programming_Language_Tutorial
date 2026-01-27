BITS 64
default rel
global _start

; Hard exercise (with solution): Saturating absolute value for signed 64-bit.
; abs_sat(x) = abs(x) for all x except INT64_MIN, where it returns INT64_MAX.

section .data
msg_ok   db "OK", 10
msg_ok_len equ $-msg_ok
msg_fail db "FAIL", 10
msg_fail_len equ $-msg_fail

section .text
abs_sat_i64:
    ; Input: RDI=x
    ; Output: RAX = abs_sat(x)
    mov rbx, rdi                   ; keep original for INT64_MIN check

    mov rax, rdi
    mov rcx, rax
    sar rcx, 63                    ; rcx = 0 or -1
    xor rax, rcx
    sub rax, rcx                   ; abs via (x ^ sign) - sign (branchless)

    ; If original x == INT64_MIN, replace result with INT64_MAX
    mov rdx, 0x8000000000000000
    cmp rbx, rdx
    mov rcx, 0x7fffffffffffffff
    cmove rax, rcx
    ret

print_ok:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_ok
    mov rdx, msg_ok_len
    syscall
    ret

print_fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_fail
    mov rdx, msg_fail_len
    syscall
    ret

_start:
    ; Test 1: x = -5 => 5
    mov rdi, -5
    call abs_sat_i64
    cmp rax, 5
    jne .fail

    ; Test 2: x = 0 => 0
    mov rdi, 0
    call abs_sat_i64
    cmp rax, 0
    jne .fail

    ; Test 3: x = INT64_MIN => INT64_MAX (saturate)
    mov rdi, 0x8000000000000000
    call abs_sat_i64
    cmp rax, 0x7fffffffffffffff
    jne .fail

    call print_ok
    xor rdi, rdi
    jmp .exit

.fail:
    call print_fail
    mov rdi, 1

.exit:
    mov rax, 60
    syscall
