; Chapter 4 - Lesson 5 (Support Include)
; File: Chapter4_Lesson5_Ex1.asm
; Purpose: Minimal Linux x86-64 helpers for printing and syscalls (NASM).
;
; Usage:
;   %include "Chapter4_Lesson5_Ex1.asm"
;
; Notes:
; - Intended to be included from other .asm files (it has no _start label).
; - Routines use Linux syscalls; target platform: Linux x86-64 (SysV ABI).

%ifndef CH4_L5_IO64_INCLUDED
%define CH4_L5_IO64_INCLUDED 1

; ----------------------------
; Syscall macros (Linux x86-64)
; ----------------------------
%macro SYS_EXIT 1
    mov eax, 60          ; __NR_exit
    mov edi, %1          ; status
    syscall
%endmacro

%macro SYS_WRITE 2
    mov eax, 1           ; __NR_write
    mov edi, 1           ; fd = stdout
    lea rsi, [%1]        ; buf
    mov edx, %2          ; len
    syscall
%endmacro

section .rodata
hex_digits: db "0123456789ABCDEF"
nl:         db 10

section .bss
hexbuf:     resb 19      ; "0x" + 16 hex digits + "\n"

section .text

; -----------------------------------------
; void print_cstr(rsi = pointer to 0-terminated string)
; Clobbers: rax, rdi, rdx, rcx
; -----------------------------------------
print_cstr:
    push rcx
    push rdi
    mov rdi, rsi
    xor ecx, ecx
.count:
    cmp byte [rdi + rcx], 0
    je .len_done
    inc rcx
    jmp .count
.len_done:
    mov eax, 1           ; write
    mov edi, 1           ; stdout
    mov rdx, rcx         ; len
    syscall
    pop rdi
    pop rcx
    ret

; -----------------------------------------
; void print_nl()
; Clobbers: rax, rdi, rsi, rdx
; -----------------------------------------
print_nl:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel nl]
    mov edx, 1
    syscall
    ret

; -----------------------------------------
; void print_hex64(rax = value)
; Prints: 0xXXXXXXXXXXXXXXXX\n
; Preserves: rbx, rcx, rdx
; Clobbers: rax, rdi, rsi
; -----------------------------------------
print_hex64:
    push rbx
    push rcx
    push rdx

    mov rbx, rax

    lea rdi, [rel hexbuf]
    mov byte [rdi], '0'
    mov byte [rdi + 1], 'x'

    lea rsi, [rdi + 2]
    mov rcx, 16

.hex_loop:
    mov rax, rbx
    shr rax, 60
    and eax, 0xF
    mov dl, [rel hex_digits + rax]
    mov [rsi], dl
    inc rsi
    shl rbx, 4
    loop .hex_loop

    mov byte [rdi + 18], 10

    mov eax, 1           ; write
    mov edi, 1           ; stdout
    lea rsi, [rel hexbuf]
    mov edx, 19
    syscall

    pop rdx
    pop rcx
    pop rbx
    ret

%endif
