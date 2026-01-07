BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
hdr   db "atoi_dec demo (parsing decimal ASCII into uint64) with overflow checking",10,0
in1   db "18446744073709551615",0    ; UINT64_MAX
in2   db "18446744073709551616",0    ; overflow
in3   db "12A34",0                    ; invalid
lab   db "Input: ",0
resok db "  Parsed value: ",0
resek db "  Error: invalid decimal or overflow",10,0

section .text
global _start

; -----------------------------------------------------------------------------
; atoi_dec
;   rsi = pointer to NUL-terminated string (optional leading '+')
;   returns:
;     rax = value
;     CF  = 0 success, CF = 1 failure (invalid char / empty / overflow)
; -----------------------------------------------------------------------------
atoi_dec:
    push rbx
    xor rax, rax
    xor ebx, ebx              ; digit count

    cmp byte [rsi], '+'
    jne .loop
    inc rsi

.loop:
    mov dl, [rsi]
    cmp dl, 0
    je .done_check

    cmp dl, '0'
    jb .fail
    cmp dl, '9'
    ja .fail

    movzx r8d, dl
    sub r8d, '0'

    ; rax = rax*10 + digit, but detect overflow:
    mov rcx, 10
    mul rcx                   ; rdx:rax = rax*10
    test rdx, rdx
    jnz .overflow
    add rax, r8
    jc .overflow

    inc ebx
    inc rsi
    jmp .loop

.done_check:
    test ebx, ebx
    jz .fail
    clc
    pop rbx
    ret

.overflow:
.fail:
    stc
    pop rbx
    ret

; -----------------------------------------------------------------------------
; driver
; -----------------------------------------------------------------------------
_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    lea rsi, [in1]
    call demo_one

    lea rsi, [in2]
    call demo_one

    lea rsi, [in3]
    call demo_one

    mov eax, SYS_exit
    xor edi, edi
    syscall

demo_one:
    push rsi
    mov rdi, STDOUT
    lea rsi, [lab]
    call print_cstr
    pop rsi
    push rsi
    mov rdi, STDOUT
    call print_cstr
    call print_nl

    pop rsi
    call atoi_dec
    jc .err

    mov rdi, STDOUT
    lea rsi, [resok]
    call print_cstr

    mov rdi, rax
    call print_dec_u64
    call print_nl
    ret

.err:
    mov rdi, STDOUT
    lea rsi, [resek]
    call print_cstr
    ret
