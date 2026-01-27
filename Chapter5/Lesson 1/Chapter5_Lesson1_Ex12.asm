BITS 64
default rel
global _start

; Very hard exercise (with solution): 3-way compare for signed 64-bit without branching.
; cmp3_i64(a,b) returns:
;   -1 if a < b
;    0 if a == b
;   +1 if a > b
; Uses SETcc + arithmetic combination.

section .data
msg_ok   db "OK", 10
msg_ok_len equ $-msg_ok
msg_fail db "FAIL", 10
msg_fail_len equ $-msg_fail

section .text
cmp3_i64:
    ; Inputs: RDI=a, RSI=b
    ; Output: RAX in {-1,0,1}
    mov rax, rdi
    cmp rax, rsi
    setl al                    ; a < b (signed)
    setg bl                    ; a > b (signed)

    movzx eax, al
    movzx ebx, bl
    sub ebx, eax               ; (a>b) - (a<b) => 1, 0, -1

    movsx rax, ebx
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
    ; a=5, b=9 => -1
    mov rdi, 5
    mov rsi, 9
    call cmp3_i64
    cmp rax, -1
    jne .fail

    ; a=9, b=5 => +1
    mov rdi, 9
    mov rsi, 5
    call cmp3_i64
    cmp rax, 1
    jne .fail

    ; a=-7, b=-7 => 0
    mov rdi, -7
    mov rsi, -7
    call cmp3_i64
    cmp rax, 0
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
