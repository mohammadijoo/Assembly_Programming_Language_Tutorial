; Chapter5_Lesson5_Ex1.asm
; Topic: BREAK in a WHILE-style loop (early exit search)
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1

BITS 64
default rel

%macro SYS_WRITE 2
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; fd = stdout
    mov     rsi, %1
    mov     rdx, %2
    syscall
%endmacro

%macro SYS_EXIT 1
    mov     rax, 60         ; sys_exit
    mov     rdi, %1
    syscall
%endmacro

section .data
    arr         db 4, 7, 2, 9, 5, 9, 1
    arr_len     equ $ - arr
    target      db 9

    msg_found   db "Found target at index: "
    msg_found_len equ $ - msg_found

    msg_nf      db "Target not found", 10
    msg_nf_len  equ $ - msg_nf

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     rbx, rbx                 ; i = 0

.while_test:
    cmp     rbx, arr_len
    jae     .not_found               ; if i >= len: stop

    mov     al, [arr + rbx]          ; load arr[i]
    cmp     al, [target]
    je      .found                   ; BREAK

    inc     rbx
    jmp     .while_test

.found:
    SYS_WRITE msg_found, msg_found_len
    mov     rdi, rbx                 ; print index
    call    print_u64_ln
    SYS_EXIT 0

.not_found:
    SYS_WRITE msg_nf, msg_nf_len
    SYS_EXIT 1

; -----------------------------------------
; print_u64_ln: print unsigned integer in RDI followed by newline
; clobbers: RAX,RBX,RCX,RDX,RSI,R8
; -----------------------------------------
print_u64_ln:
    lea     r8,  [outbuf + 31]       ; last byte
    mov     byte [r8], 10            ; '\n'
    lea     rsi, [outbuf + 30]       ; write digits backward before newline

    mov     rax, rdi
    cmp     rax, 0
    jne     .conv

    mov     byte [rsi], '0'
    mov     rdx, 2                   ; "0\n"
    lea     rsi, [rsi]               ; rsi already points to '0'
    jmp     .emit

.conv:
    mov     rbx, 10
.loop:
    xor     rdx, rdx
    div     rbx                      ; RAX = RAX/10, RDX = remainder
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    rax, rax
    jnz     .loop

    inc     rsi                      ; point to first digit
    lea     rdx, [outbuf + 32]
    sub     rdx, rsi                 ; length from first digit to end (includes newline)

.emit:
    SYS_WRITE rsi, rdx
    ret
