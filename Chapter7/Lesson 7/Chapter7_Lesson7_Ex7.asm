; Chapter7_Lesson7_Ex7.asm
; Guard page demo WITHOUT crashing: allocate 3 pages with mmap, mark the middle page PROT_NONE,
; then implement a bounded "software stack" on the last page. When the stack would cross into the
; guard page, we detect overflow and stop safely.
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson7_Ex7.asm -o ex7.o && ld -o ex7 ex7.o

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
msg_over: db "overflow prevented before guard page", 10
msg_over_len: equ $-msg_over
msg_done: db "done", 10
msg_done_len: equ $-msg_done

section .text

_start:
    ; mmap(NULL, 3*4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor     rdi, rdi
    mov     rsi, 3*4096
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_PRIVATE | MAP_ANON
    mov     r8, -1
    xor     r9, r9
    mov     eax, SYS_mmap
    syscall

    ; rax = base
    mov     rbx, rax

    ; mprotect(base + 4096, 4096, PROT_NONE) => middle page is guard
    lea     rdi, [rbx + 4096]
    mov     rsi, 4096
    mov     rdx, PROT_NONE
    mov     eax, SYS_mprotect
    syscall

    ; Software stack spans the LAST page: [base+8192, base+12288)
    lea     r12, [rbx + 3*4096]    ; sp = top (grows down)
    lea     r13, [rbx + 2*4096]    ; low limit (start of last page)

    ; Push qwords until we'd cross below r13 (into guard page).
    mov     ecx, 800               ; try to push 800 * 8 = 6400 bytes (overflow would happen)

.push_loop:
    test    ecx, ecx
    jz      .finish

    lea     rax, [r12 - 8]         ; next_sp
    cmp     rax, r13
    jb      .overflow              ; next_sp < low_limit

    mov     r12, rax
    mov     qword [r12], rcx       ; payload
    dec     ecx
    jmp     .push_loop

.overflow:
    ; Print message and exit cleanly
    mov     rdi, 1
    mov     rsi, msg_over
    mov     rdx, msg_over_len
    mov     eax, SYS_write
    syscall
    xor     edi, edi
    mov     eax, SYS_exit
    syscall

.finish:
    mov     rdi, 1
    mov     rsi, msg_done
    mov     rdx, msg_done_len
    mov     eax, SYS_write
    syscall

    xor     edi, edi
    mov     eax, SYS_exit
    syscall
