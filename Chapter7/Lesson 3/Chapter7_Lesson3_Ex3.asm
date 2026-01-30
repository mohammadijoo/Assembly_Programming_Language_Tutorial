; Chapter 7 - Lesson 3 - Example 3
; realloc growth + preserving data
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex3.asm -o ex3.o
;   gcc -no-pie ex3.o -o ex3

default rel
global main
extern malloc
extern realloc
extern free
extern printf

section .data
msg1 db "hello", 0
msg2 db "hello, realloc world!", 0
fmt  db "after realloc: %s", 10, 0

section .text
; tiny helper: copy a null-terminated string (RSI -> RDI), returns RDI in RAX
strcpy_simple:
    push rbp
    mov  rbp, rsp
.copy:
    mov  al, [rsi]
    mov  [rdi], al
    inc  rsi
    inc  rdi
    test al, al
    jne  .copy
    mov  rax, rdi
    pop  rbp
    ret

main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8

    mov  edi, 16               ; initial size
    call malloc
    test rax, rax
    jz   .fail
    mov  rbx, rax

    ; copy "hello" into buffer
    lea  rsi, [msg1]
    mov  rdi, rbx
    call strcpy_simple

    ; grow to 64 bytes
    mov  rdi, rbx              ; old ptr
    mov  esi, 64               ; new size
    call realloc
    test rax, rax
    jz   .fail_free_old         ; realloc failure leaves old block valid
    mov  rbx, rax

    ; overwrite with longer string
    lea  rsi, [msg2]
    mov  rdi, rbx
    call strcpy_simple

    lea  rdi, [fmt]
    mov  rsi, rbx
    xor  eax, eax
    call printf

    mov  rdi, rbx
    call free

    xor  eax, eax
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

.fail_free_old:
    ; on realloc failure, free old pointer
    mov  rdi, rbx
    call free
.fail:
    mov  eax, 1
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret
