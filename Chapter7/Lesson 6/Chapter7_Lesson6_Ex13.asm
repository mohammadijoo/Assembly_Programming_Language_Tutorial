; Chapter7_Lesson6_Ex13.asm
; Exercise Solution 3:
; memcpy-like routine with:
;   - alignment fixup
;   - SSE2 bulk copy (16B/iter)
;   - optional non-temporal path for large sizes
;
; This is a teaching implementation; real-world memcpy has many CPU-specific paths.

%include "Chapter7_Lesson6_Ex1.asm"

default rel
global _start

%define NBYTES (64*1024*1024)
%define NT_THRESHOLD (8*1024*1024)

section .text
_start:
    lea rdi, [rel title]
    call mem_write_cstr

    ; init src
    lea rdi, [rel src]
    mov rcx, NBYTES/8
    mov rax, 0x0123456789ABCDEF
.init:
    mov [rdi], rax
    add rdi, 8
    rol rax, 1
    dec rcx
    jnz .init

    ; time copy
    call mem_tsc
    mov r12, rax

    lea rsi, [rel src]
    lea rdi, [rel dst]
    mov rdx, NBYTES
    call mem_memcpy_sse2

    call mem_tsc
    sub rax, r12
    lea rdi, [rel msg]
    call mem_write_cstr
    mov rdi, rax
    call mem_write_hex64

    xor rdi, rdi
    mov rax, SYS_exit
    syscall

; ------------------------------------------------------------
; mem_memcpy_sse2(rdi=dst, rsi=src, rdx=len)   clobbers rax,rcx,r8,xmm0
; ------------------------------------------------------------
mem_memcpy_sse2:
    ; align dst to 16 bytes by copying leading bytes
    test rdx, rdx
    jz .done

.align_fix:
    test rdi, 15
    jz  .bulk
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rdx
    jnz .align_fix
    jmp .done

.bulk:
    cmp rdx, 16
    jb  .tail

    ; choose non-temporal path for large copies
    cmp rdx, NT_THRESHOLD
    jb  .cached_loop

.nt_loop:
    movdqu xmm0, [rsi]
    movntdq [rdi], xmm0
    add rsi, 16
    add rdi, 16
    sub rdx, 16
    cmp rdx, 16
    jae .nt_loop
    sfence
    jmp .tail

.cached_loop:
    movdqu xmm0, [rsi]
    movdqu [rdi], xmm0
    add rsi, 16
    add rdi, 16
    sub rdx, 16
    cmp rdx, 16
    jae .cached_loop

.tail:
    test rdx, rdx
    jz .done
.tail_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rdx
    jnz .tail_loop

.done:
    ret

section .rodata
title: db "Ex13 (solution): memcpy SSE2 + optional non-temporal for large sizes",10,0
msg:   db "cycles(memcpy): ",0

section .bss
align 16
src: resb NBYTES
dst: resb NBYTES
