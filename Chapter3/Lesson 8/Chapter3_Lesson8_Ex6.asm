BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
hdr   db "atoi_hex demo (parsing hex ASCII into uint64)",10,0
in1   db "0xDEADBEEF",0
in2   db "BADC0FFEE0DDF00D",0
in3   db "xyz",0
lab   db "Input: ",0
resok db "  Parsed value: ",0
resek db "  Error: invalid hex or overflow",10,0
nl2   db 10,0

section .text
global _start

; -----------------------------------------------------------------------------
; atoi_hex
;   rsi = pointer to NUL-terminated string (optional "0x"/"0X" prefix)
;   returns:
;     rax = value
;     CF  = 0 success, CF = 1 failure (invalid char / empty / overflow)
; -----------------------------------------------------------------------------
atoi_hex:
    push rbx
    xor rax, rax
    xor ebx, ebx              ; digit count

    ; Optional prefix 0x / 0X
    cmp byte [rsi], '0'
    jne .loop
    mov dl, [rsi+1]
    cmp dl, 'x'
    je .skip2
    cmp dl, 'X'
    jne .loop
.skip2:
    add rsi, 2

.loop:
    mov dl, [rsi]
    cmp dl, 0
    je .done_check

    ; Convert DL to nibble in ECX
    cmp dl, '0'
    jb .fail
    cmp dl, '9'
    jbe .digit
    cmp dl, 'A'
    jb .lower_check
    cmp dl, 'F'
    jbe .upper
.lower_check:
    cmp dl, 'a'
    jb .fail
    cmp dl, 'f'
    jbe .lower
    jmp .fail

.digit:
    movzx ecx, dl
    sub ecx, '0'
    jmp .have

.upper:
    movzx ecx, dl
    sub ecx, 'A'
    add ecx, 10
    jmp .have

.lower:
    movzx ecx, dl
    sub ecx, 'a'
    add ecx, 10

.have:
    ; Overflow check for (rax << 4): top 4 bits must be zero
    test rax, 0xF000000000000000
    jnz .overflow

    shl rax, 4
    add rax, rcx

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

    ; parse in1
    lea rsi, [in1]
    call demo_one

    ; parse in2
    lea rsi, [in2]
    call demo_one

    ; parse in3
    lea rsi, [in3]
    call demo_one

    mov eax, SYS_exit
    xor edi, edi
    syscall

; -----------------------------------------------------------------------------
; demo_one
;   rsi = input string
; -----------------------------------------------------------------------------
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
    call atoi_hex
    jc .err

    mov rdi, STDOUT
    lea rsi, [resok]
    call print_cstr

    mov rdi, rax
    call print_hex64
    call print_nl
    ret

.err:
    mov rdi, STDOUT
    lea rsi, [resek]
    call print_cstr
    ret
