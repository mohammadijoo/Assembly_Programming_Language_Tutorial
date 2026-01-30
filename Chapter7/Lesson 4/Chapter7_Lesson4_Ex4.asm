; Chapter 7 - Lesson 4 - Example 4
; posix_memalign for explicit alignment (useful for SIMD / cacheline alignment).
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex4.asm -o ex4.o
;   gcc -no-pie ex4.o -o ex4

default rel

global main
extern posix_memalign
extern free
extern printf
extern exit

section .data
fmt_ok  db "ptr=%p  (ptr mod 32)=%ld", 10, 0
fmt_err db "posix_memalign failed: rc=%d", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 48

    mov  qword [rbp-8], 0       ; void* p = NULL

    lea  rdi, [rbp-8]           ; &p
    mov  esi, 32                ; alignment (must be power-of-two, multiple of sizeof(void*))
    mov  edx, 1024              ; size
    call posix_memalign
    test eax, eax
    jnz  .err

    mov  rax, [rbp-8]
    mov  rdx, rax
    and  rdx, 31                ; remainder
    lea  rdi, [fmt_ok]
    mov  rsi, rax               ; %p
    ; third printf arg goes in rdx already
    xor  eax, eax
    call printf

    mov  rdi, [rbp-8]
    call free

    xor  eax, eax
    leave
    ret

.err:
    lea  rdi, [fmt_err]
    mov  esi, eax
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit
