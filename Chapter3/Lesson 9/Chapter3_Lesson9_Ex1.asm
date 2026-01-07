; Chapter 3 - Lesson 9 (Two's Complement Deep Dive)
; Ex1: Minimal Linux x86-64 I/O + numeric printing utilities for the lesson examples
;
; Usage:
;   In other examples, put this line near the top:
;       %include "Chapter3_Lesson9_Ex1.asm"
;   Then you can use:
;       PRINTZ label
;       call print_hex64_nl      ; value in RAX
;       call print_u64_nl        ; value in RAX
;       call print_i64_nl        ; value in RAX (signed)
;       call print_nl
;       call exit0
;
; Assemble/link (example):
;   nasm -felf64 Chapter3_Lesson9_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

%ifndef C3L9_UTILS_INCLUDED
%define C3L9_UTILS_INCLUDED 1

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define FD_STDOUT 1

section .data
hex_digits: db "0123456789ABCDEF"
nl:         db 10
minus_ch:   db "-"

section .bss
hexbuf:  resb 19           ; "0x" + 16 hex digits + "\n"  => 19 bytes
decbuf:  resb 32           ; enough for uint64 decimal text

section .text

; ---------------------------------------------
; write_stdout
;   Inputs: RSI=buffer, RDX=length
;   Clobbers: RAX, RDI
; ---------------------------------------------
write_stdout:
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
    ret

; ---------------------------------------------
; print_nl
; ---------------------------------------------
print_nl:
    lea rsi, [nl]
    mov edx, 1
    jmp write_stdout

; ---------------------------------------------
; print_cstr
;   Inputs: RDI = pointer to zero-terminated string
;   Clobbers: RAX, RCX, RDX, RSI
; ---------------------------------------------
print_cstr:
    mov rsi, rdi
    xor edx, edx
.len:
    cmp byte [rsi + rdx], 0
    je .out
    inc edx
    jmp .len
.out:
    ; RSI already holds buffer pointer; RDX holds length
    jmp write_stdout

%macro PRINTZ 1
    lea rdi, [%1]
    call print_cstr
%endmacro

; ---------------------------------------------
; print_char
;   Inputs: AL = character
; ---------------------------------------------
print_char:
    sub rsp, 8
    mov [rsp], al
    mov rsi, rsp
    mov edx, 1
    call write_stdout
    add rsp, 8
    ret

; ---------------------------------------------
; print_hex64_nl
;   Inputs: RAX = value
;   Output: prints "0x" + 16 hex digits + "\n"
;   Clobbers: RAX, RBX, RCX, RDX, RDI, RSI
; ---------------------------------------------
print_hex64_nl:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    lea rsi, [hexbuf]
    mov byte [rsi + 0], '0'
    mov byte [rsi + 1], 'x'

    mov rbx, rax
    lea rdi, [rsi + 2]
    mov ecx, 16
.hex_loop:
    mov rdx, rbx
    shr rdx, 60
    and edx, 0xF
    mov dl, [hex_digits + rdx]
    mov [rdi], dl
    inc rdi
    shl rbx, 4
    dec ecx
    jnz .hex_loop

    mov byte [rsi + 18], 10
    mov edx, 19
    call write_stdout

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; ---------------------------------------------
; print_u64_nl
;   Inputs: RAX = value (unsigned)
;   Output: decimal + "\n"
;   Clobbers: RAX, RBX, RCX, RDX, RDI, RSI
; ---------------------------------------------
print_u64_nl:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    mov rbx, 10
    lea rdi, [decbuf + 32]     ; build digits backward
    xor ecx, ecx               ; digit count

    test rax, rax
    jnz .conv

    ; value = 0 special case
    dec rdi
    mov byte [rdi], '0'
    mov ecx, 1
    jmp .emit

.conv:
    ; while (RAX != 0) { RDX:RAX / 10; remainder in RDX }
.u_loop:
    xor edx, edx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc ecx
    test rax, rax
    jnz .u_loop

.emit:
    mov rsi, rdi
    mov edx, ecx
    call write_stdout
    call print_nl

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; ---------------------------------------------
; print_i64_nl
;   Inputs: RAX = value (signed)
;   Output: signed decimal + "\n"
;   Notes:
;     - For INT64_MIN, NEG leaves the value unchanged but we still print magnitude correctly.
;   Clobbers: RAX, RBX, RCX, RDX, RDI, RSI
; ---------------------------------------------
print_i64_nl:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    test rax, rax
    jns .pos

    ; print '-'
    mov al, '-'
    call print_char

    ; magnitude = -value (as unsigned)
    neg rax

.pos:
    ; reuse unsigned converter but without re-printing '-' and without extra newline
    mov rbx, 10
    lea rdi, [decbuf + 32]
    xor ecx, ecx

    test rax, rax
    jnz .conv

    dec rdi
    mov byte [rdi], '0'
    mov ecx, 1
    jmp .emit

.conv:
.i_loop:
    xor edx, edx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc ecx
    test rax, rax
    jnz .i_loop

.emit:
    mov rsi, rdi
    mov edx, ecx
    call write_stdout
    call print_nl

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; ---------------------------------------------
; exit0 / exit_code
; ---------------------------------------------
exit0:
    xor edi, edi
    mov eax, SYS_exit
    syscall

exit_code:
    ; RDI = code
    mov eax, SYS_exit
    syscall

%endif
