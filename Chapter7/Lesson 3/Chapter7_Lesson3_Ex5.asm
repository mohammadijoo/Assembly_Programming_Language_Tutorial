; Chapter 7 - Lesson 3 - Example 5
; Aligned allocations with posix_memalign
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex5.asm -o ex5.o
;   gcc -no-pie ex5.o -o ex5
;
; int posix_memalign(void **memptr, size_t alignment, size_t size);
; Returns 0 on success, else error code (and does NOT set errno in the same way as malloc).

default rel
global main
extern posix_memalign
extern free
extern printf

section .data
fmt_ok  db "aligned ptr = %p (alignment=%d)", 10, 0
fmt_bad db "posix_memalign failed, code=%d", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 24               ; local space + keep alignment
    ; Layout: [rbp-8]  = ptr (qword)
    ;         [rbp-16] = padding
    ;         [rbp-24] = padding

    lea  rdi, [rbp-8]          ; void** memptr
    mov  esi, 64               ; alignment (must be power of two and multiple of sizeof(void*))
    mov  edx, 256              ; size
    call posix_memalign

    test eax, eax
    jnz  .fail

    mov  rbx, [rbp-8]          ; load allocated pointer

    lea  rdi, [fmt_ok]
    mov  rsi, rbx
    mov  edx, 64
    xor  eax, eax
    call printf

    mov  rdi, rbx
    call free
    xor  eax, eax
    add  rsp, 24
    pop  rbx
    pop  rbp
    ret

.fail:
    lea  rdi, [fmt_bad]
    mov  esi, eax
    xor  eax, eax
    call printf
    mov  eax, 1
    add  rsp, 24
    pop  rbx
    pop  rbp
    ret
