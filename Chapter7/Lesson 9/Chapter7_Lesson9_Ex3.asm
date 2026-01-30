; Chapter7_Lesson9_Ex3.asm
; Check alignment of pointers returned by malloc (typically 16-byte aligned on x86-64).
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex3.asm -o ex3.o
;   gcc ex3.o -o ex3
; Run:
;   ./ex3

default rel
global main
extern malloc
extern free
extern printf

section .rodata
sizes: dq 1, 2, 3, 15, 16, 17, 31, 32, 63, 64
n_sizes: equ 10
fmt: db "size=%llu  ptr=%p  (ptr & 0xF)=%llu", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    xor ebx, ebx                 ; i = 0
.loop:
    cmp ebx, n_sizes
    jge .done

    mov rdi, [sizes + rbx*8]     ; size
    call malloc                  ; rax = ptr
    mov r12, rax                 ; save ptr

    ; mod16 = ptr & 0xF
    mov r13, r12
    and r13, 0xF

    ; printf(fmt, size, ptr, mod16)
    lea rdi, [fmt]
    mov rsi, [sizes + rbx*8]
    mov rdx, r12
    mov rcx, r13
    xor eax, eax
    call printf

    ; free(ptr)
    mov rdi, r12
    call free

    inc ebx
    jmp .loop

.done:
    xor eax, eax
    leave
    ret
