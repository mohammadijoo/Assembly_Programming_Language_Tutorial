; Chapter7_Lesson7_Ex12.asm
; Exercise Solution 3:
; A "guarded stack" abstraction built on top of mmap+mprotect, with explicit bounds checks.
; We allocate 4 pages:
;   [page0][guard page1][usable page2][usable page3]
; and implement push/pop on a software SP that grows down inside the usable area.
;
; This demonstrates the guard-page idea without relying on a crash.

%define SYS_exit     60
%define SYS_write    1
%define SYS_mmap      9
%define SYS_mprotect 10

%define PROT_NONE  0
%define PROT_READ  1
%define PROT_WRITE 2

%define MAP_PRIVATE   0x02
%define MAP_ANON      0x20

global _start

section .rodata
msg_ok:  db "guarded stack passed", 10
msg_ok_len: equ $-msg_ok
msg_fail: db "guarded stack failed", 10
msg_fail_len: equ $-msg_fail

section .text

_start:
    ; mmap(NULL, 4*4096, RW, PRIVATE|ANON, -1, 0)
    xor     rdi, rdi
    mov     rsi, 4*4096
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_PRIVATE | MAP_ANON
    mov     r8, -1
    xor     r9, r9
    mov     eax, SYS_mmap
    syscall
    mov     rbx, rax                 ; base

    ; guard page at page1: mprotect(base+4096, 4096, NONE)
    lea     rdi, [rbx + 4096]
    mov     rsi, 4096
    mov     rdx, PROT_NONE
    mov     eax, SYS_mprotect
    syscall

    ; usable region = pages 2 and 3: [base+8192, base+16384)
    lea     r12, [rbx + 4*4096]      ; sp = top
    lea     r13, [rbx + 2*4096]      ; low_limit

    ; Push 100 values (LIFO), then pop and verify.
    mov     ecx, 100
.push:
    test    ecx, ecx
    jz      .pop_setup
    mov     edi, ecx
    call    gs_push
    dec     ecx
    jmp     .push

.pop_setup:
    mov     ecx, 1

.pop:
    cmp     ecx, 101
    je      .success
    call    gs_pop                  ; rax = value
    cmp     eax, ecx
    jne     .failure
    inc     ecx
    jmp     .pop

.success:
    mov     rdi, 1
    mov     rsi, msg_ok
    mov     rdx, msg_ok_len
    mov     eax, SYS_write
    syscall
    xor     edi, edi
    mov     eax, SYS_exit
    syscall

.failure:
    mov     rdi, 1
    mov     rsi, msg_fail
    mov     rdx, msg_fail_len
    mov     eax, SYS_write
    syscall
    mov     edi, 1
    mov     eax, SYS_exit
    syscall

; gs_push(edi=value)
; uses r12=sp, r13=low_limit
gs_push:
    lea     rax, [r12 - 8]
    cmp     rax, r13
    jb      .overflow
    mov     r12, rax
    mov     dword [r12], edi
    ret
.overflow:
    ; treat overflow as failure
    jmp     _start.failure

; gs_pop() -> eax=value
gs_pop:
    ; Underflow if sp == top (base+4*4096)
    lea     rax, [rbx + 4*4096]
    cmp     r12, rax
    jae     .underflow
    mov     eax, dword [r12]
    add     r12, 8
    ret
.underflow:
    jmp     _start.failure
