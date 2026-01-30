; Chapter7_Lesson9_Ex13.asm
; Programming Exercise Solution:
; A debug_free(ptr, bytes) wrapper that poisons memory with 0xCC before free(ptr).
; This is a common allocator-debug technique (detecting use-after-free visually).
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex13.asm -o ex13.o
;   gcc ex13.o -o ex13
; Run:
;   ./ex13

default rel
global main
extern malloc
extern free
extern printf

section .rodata
fmt: db "ptr=%p  poisoned_first_byte=%#x", 10, 0

section .text
debug_free:
    ; rdi = ptr, rsi = bytes
    test rdi, rdi
    jz .ret

    push rbp                      ; align for call free
    mov rbp, rsp
    sub rsp, 16

    ; poison with 0xCC using rep stosb
    mov rdx, rdi                  ; save ptr for free
    mov rcx, rsi                  ; count
    mov al, 0xCC
    cld
    rep stosb

    mov rdi, rdx
    call free

    leave
.ret:
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    mov edi, 64
    call malloc
    mov r12, rax

    ; write something then read first byte
    mov byte [r12], 0x11
    movzx edx, byte [r12]

    lea rdi, [fmt]
    mov rsi, r12
    xor eax, eax
    call printf

    ; poison+free (bytes = 64)
    mov rdi, r12
    mov esi, 64
    call debug_free

    xor eax, eax
    leave
    ret
