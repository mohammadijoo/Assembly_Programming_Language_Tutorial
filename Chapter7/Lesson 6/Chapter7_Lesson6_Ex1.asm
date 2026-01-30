; Chapter7_Lesson6_Ex1.asm
; Common helpers for the memory-hierarchy microbench programs (NASM, Linux x86-64).
;
; Usage:
;   %include "Chapter7_Lesson6_Ex1.asm"
;
; Conventions (simple, not ABI-perfect):
;   - mem_write_buf:   rdi=buf, rsi=len
;   - mem_write_cstr:  rdi=0-terminated string
;   - mem_write_nl:    prints '\n'
;   - mem_write_hex64: rdi=value (prints 0x + 16 hex digits + '\n')
;   - mem_tsc:         returns TSC in rax (serialized by LFENCE+RDTSCP+LFENCE)
;
; Build note:
;   This file is meant to be INCLUDED. It does not define an entry point.

%ifndef CH7L6_MEMTOOLS_INCLUDED
%define CH7L6_MEMTOOLS_INCLUDED 1

default rel

%define SYS_write   1
%define SYS_exit    60
%define SYS_mmap    9
%define SYS_munmap  11

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    32

section .text

; ---- Timing ----
mem_tsc:
    lfence
    rdtscp              ; edx:eax = TSC, ecx = IA32_TSC_AUX
    shl rdx, 32
    or  rax, rdx
    lfence
    ret

; ---- Syscall helpers ----
mem_write_buf:
    ; rdi=buf, rsi=len
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1          ; fd=stdout
    mov rax, SYS_write
    syscall
    ret

mem_write_cstr:
    ; rdi = c-string
    push rdi
    xor rcx, rcx
.len_loop:
    cmp byte [rdi+rcx], 0
    je  .got_len
    inc rcx
    jmp .len_loop
.got_len:
    mov rsi, rcx        ; len
    pop rdi             ; buf
    jmp mem_write_buf

mem_write_nl:
    lea rdi, [rel mem_nl]
    mov rsi, 1
    jmp mem_write_buf

mem_write_hex64:
    ; rdi=value
    lea rbx, [rel mem_hex_digits]
    lea rsi, [rel mem_hex_buf]
    mov byte [rsi+0], '0'
    mov byte [rsi+1], 'x'

    mov rax, rdi
    mov rcx, 16
    lea rdi, [rsi+2+15]     ; last hex digit position
.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx+rdx]
    mov [rdi], dl
    shr rax, 4
    dec rdi
    dec rcx
    jnz .hex_loop

    mov byte [rsi+18-1], 10 ; '\n' (buffer is 18 bytes total)
    lea rdi, [rel mem_hex_buf]
    mov rsi, 18
    jmp mem_write_buf

%endif

section .rodata
mem_hex_digits: db "0123456789abcdef"
mem_nl: db 10

section .bss
mem_hex_buf: resb 18
