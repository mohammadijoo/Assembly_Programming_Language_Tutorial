BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
usage db "Usage: ./ex8 <number>",10,"Accepted: decimal, 0x... hex, 0b... binary",10,0
hdr   db "Input interpreted as:",10,0
dmsg  db "  decimal: ",0
hmsg  db "  hex    : ",0
bmsg  db "  binary : ",0
emsg  db "Parse error (invalid digits or overflow).",10,0

section .text
global _start

; -----------------------------------------------------------------------------
; atoi_bin
;   rsi = NUL-terminated string of '0'/'1' (no prefix)
;   returns rax=value, CF=0 ok, CF=1 error/overflow/empty
; -----------------------------------------------------------------------------
atoi_bin:
    xor rax, rax
    xor ecx, ecx              ; digit count
.loop:
    mov dl, [rsi]
    cmp dl, 0
    je .done_check

    ; overflow check: shifting left requires top bit to be 0
    test rax, 0x8000000000000000
    jnz .overflow

    shl rax, 1
    cmp dl, '0'
    je .ok
    cmp dl, '1'
    jne .fail
    inc rax
.ok:
    inc ecx
    inc rsi
    jmp .loop

.done_check:
    test ecx, ecx
    jz .fail
    clc
    ret

.overflow:
.fail:
    stc
    ret

; -----------------------------------------------------------------------------
; atoi_hex and atoi_dec reused (trimmed) for a single-file CLI tool
; -----------------------------------------------------------------------------
atoi_hex:
    xor rax, rax
    xor ecx, ecx              ; digit count

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
    movzx r8d, dl
    sub r8d, '0'
    jmp .have
.upper:
    movzx r8d, dl
    sub r8d, 'A'
    add r8d, 10
    jmp .have
.lower:
    movzx r8d, dl
    sub r8d, 'a'
    add r8d, 10

.have:
    test rax, 0xF000000000000000
    jnz .overflow
    shl rax, 4
    add rax, r8

    inc ecx
    inc rsi
    jmp .loop

.done_check:
    test ecx, ecx
    jz .fail
    clc
    ret

.overflow:
.fail:
    stc
    ret

atoi_dec:
    xor rax, rax
    xor ecx, ecx              ; digit count

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

    mov r9, rax               ; save acc
    mov rcx, 10
    mul rcx                   ; rdx:rax = acc*10
    test rdx, rdx
    jnz .overflow
    add rax, r8
    jc .overflow

    inc ecx
    inc rsi
    jmp .loop

.done_check:
    test ecx, ecx
    jz .fail
    clc
    ret

.overflow:
.fail:
    stc
    ret

; -----------------------------------------------------------------------------
; _start: parse argv[1], print in all bases
; -----------------------------------------------------------------------------
_start:
    mov rbx, rsp
    mov rax, [rbx]            ; argc
    cmp rax, 2
    jb .usage

    mov rsi, [rbx+16]         ; argv[1]

    ; Determine base by prefix
    cmp byte [rsi], '0'
    jne .dec

    mov dl, [rsi+1]
    cmp dl, 'x'
    je .hex
    cmp dl, 'X'
    je .hex
    cmp dl, 'b'
    je .bin
    cmp dl, 'B'
    je .bin

.dec:
    call atoi_dec
    jnc .ok
    jmp .err

.hex:
    call atoi_hex
    jnc .ok
    jmp .err

.bin:
    add rsi, 2
    call atoi_bin
    jnc .ok
    jmp .err

.ok:
    mov r12, rax              ; value

    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    mov rdi, STDOUT
    lea rsi, [dmsg]
    call print_cstr
    mov rdi, r12
    call print_dec_u64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [hmsg]
    call print_cstr
    mov rdi, r12
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [bmsg]
    call print_cstr
    mov rdi, r12
    call print_bin64
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall

.usage:
    mov rdi, STDOUT
    lea rsi, [usage]
    call print_cstr
    mov eax, SYS_exit
    mov edi, 1
    syscall

.err:
    mov rdi, STDOUT
    lea rsi, [emsg]
    call print_cstr
    mov eax, SYS_exit
    mov edi, 2
    syscall
