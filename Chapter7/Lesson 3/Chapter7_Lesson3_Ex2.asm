; Chapter 7 - Lesson 3 - Example 2
; calloc + observing zero-initialized memory
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex2.asm -o ex2.o
;   gcc -no-pie ex2.o -o ex2

default rel
global main
extern calloc
extern free
extern printf

section .data
fmt_hdr db "calloc returned %p, first 8 bytes:", 10, 0
fmt_row db "  byte[%d] = 0x%02x", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8                ; keep 16-byte alignment before calls

    mov  edi, 8                ; nmemb
    mov  esi, 16               ; size each
    call calloc
    test rax, rax
    jz   .fail
    mov  rbx, rax

    lea  rdi, [fmt_hdr]
    mov  rsi, rbx
    xor  eax, eax
    call printf

    xor  ecx, ecx              ; i = 0
.loop:
    cmp  ecx, 8
    jge  .done_loop

    movzx edx, byte [rbx+rcx]  ; value
    lea  rdi, [fmt_row]
    mov  esi, ecx              ; i
    ; EDX already holds value (promoted)
    xor  eax, eax
    call printf

    inc  ecx
    jmp  .loop

.done_loop:
    mov  rdi, rbx
    call free

    xor  eax, eax
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

.fail:
    mov  eax, 1
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret
