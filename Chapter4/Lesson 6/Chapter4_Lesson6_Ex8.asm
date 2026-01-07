; Chapter 4 - Lesson 6 (Stack Operations) - Exercise 2 Solution (Very Hard)
; Evaluate an RPN expression using the CPU stack as the evaluation stack.
; Supported operators: + - * / (integer division, trunc toward zero)
; Expression is embedded as an ASCII string with spaces (no stdin parsing).

default rel
global _start

section .data
hex_digits: db "0123456789ABCDEF"
hex_buf:    db "0x", 16 dup("0"), 10

expr: db "15 7 1 1 + - / 3 * 2 1 1 + + -", 0
; Classic example: 15 / (7 - (1+1)) * 3 - (2 + (1+1)) = 5

section .text
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

to_hex64:
    push rbx
    lea rbx, [hex_digits]
    mov rcx, 16
.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx + rdx]
    mov [rdi + rcx - 1], dl
    shr rax, 4
    loop .hex_loop
    pop rbx
    ret

print_hex64:
    sub rsp, 8
    lea rdi, [hex_buf + 2]
    call to_hex64
    lea rsi, [hex_buf]
    mov edx, 19
    call write_stdout
    add rsp, 8
    ret

; parse_int: parses non-negative decimal integer at [rsi], returns:
;   rax = value
;   rsi advanced past digits
parse_int:
    xor eax, eax
.pi_loop:
    mov bl, [rsi]
    cmp bl, '0'
    jb .pi_done
    cmp bl, '9'
    ja .pi_done
    imul rax, rax, 10
    sub bl, '0'
    add rax, rbx
    inc rsi
    jmp .pi_loop
.pi_done:
    ret

_start:
    ; NOTE: This program uses the CPU stack as the evaluation stack.
    ; Keep a small fixed padding to preserve alignment before CALL print_hex64 at the end.
    sub rsp, 8                                   ; reserve 8 bytes so final CALL is aligned (RSP%16=0)

    lea rsi, [expr]

.scan:
    mov al, [rsi]
    test al, al
    jz .done

    cmp al, ' '
    je .skip_space

    ; Digit?
    cmp al, '0'
    jb .maybe_op
    cmp al, '9'
    ja .maybe_op

    ; Parse number and push it
    call parse_int                               ; rax=value, rsi advanced
    push rax
    jmp .scan

.maybe_op:
    ; Operator is in AL (single char token)
    cmp al, '+'
    je .op_add
    cmp al, '-'
    je .op_sub
    cmp al, '*'
    je .op_mul
    cmp al, '/'
    je .op_div

    ; Unknown token => treat as error, push 0 and finish
    xor eax, eax
    push rax
    jmp .done

.op_add:
    pop rbx                                      ; b
    pop rax                                      ; a
    add rax, rbx
    push rax
    jmp .consume_token

.op_sub:
    pop rbx                                      ; b
    pop rax                                      ; a
    sub rax, rbx                                 ; a - b
    push rax
    jmp .consume_token

.op_mul:
    pop rbx                                      ; b
    pop rax                                      ; a
    imul rax, rbx
    push rax
    jmp .consume_token

.op_div:
    pop rbx                                      ; b (divisor)
    pop rax                                      ; a (dividend)
    cqo                                          ; sign-extend RAX into RDX:RAX
    idiv rbx                                     ; quotient in RAX
    push rax
    jmp .consume_token

.consume_token:
    inc rsi
    jmp .scan

.skip_space:
    inc rsi
    jmp .scan

.done:
    ; Result is on top of evaluation stack.
    pop rax
    add rsp, 8                                   ; undo padding so stack restored

    call print_hex64                             ; should print 0x...0005
    mov eax, 60
    xor edi, edi
    syscall
