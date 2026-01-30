; Chapter7_Lesson9_Ex4.asm
; Round requested sizes to allocator granularity (conceptual model).
; We model:
;   needed = align_up(req + overhead, alignment)
; with overhead=16 (header+footer) and alignment=16 bytes.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex4.asm -o ex4.o
;   gcc ex4.o -o ex4
; Run:
;   ./ex4

default rel
global main
extern printf

section .rodata
reqs: dq 1, 7, 8, 9, 15, 16, 17, 24, 31, 32, 33, 63, 64, 65
n_reqs: equ 14
fmt: db "req=%3llu  rounded_needed=%3llu", 10, 0

section .text
align_up_16:
    ; rdi = x
    ; return rax = (x + 15) & -16
    lea rax, [rdi + 15]
    and rax, -16
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    xor ebx, ebx
.loop:
    cmp ebx, n_reqs
    jge .done

    mov rdi, [reqs + rbx*8]      ; req
    mov r12, rdi                 ; keep req

    ; x = req + overhead(16)
    add rdi, 16
    call align_up_16             ; rax = rounded needed
    mov r13, rax

    lea rdi, [fmt]
    mov rsi, r12                 ; req
    mov rdx, r13                 ; rounded
    xor eax, eax
    call printf

    inc ebx
    jmp .loop

.done:
    xor eax, eax
    leave
    ret
