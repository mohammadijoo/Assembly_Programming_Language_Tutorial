; Chapter5_Lesson5_Ex11.asm
; Exercise Solution 5 (Very Hard):
; DO-WHILE-style loop with CONTINUE and BREAK.
; Process bytes until sentinel 255 => BREAK. Skip zeros => CONTINUE.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o

BITS 64
default rel

%macro SYS_WRITE 2
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2
    syscall
%endmacro

%macro SYS_EXIT 1
    mov     rax, 60
    mov     rdi, %1
    syscall
%endmacro

section .data
    buf         db 1, 2, 0, 3, 4, 255, 5
    msg         db "Sum until 255 (skipping zeros): "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    lea     rsi, [buf]               ; ptr
    xor     r12, r12                 ; sum = 0

.do_body:
    movzx   rax, byte [rsi]          ; current byte in AL
    cmp     al, 255
    je      .break_out               ; BREAK

    cmp     al, 0
    je      .continue_step           ; CONTINUE

    add     r12, rax

.continue_step:
    inc     rsi                      ; step (advance pointer)

    ; DO-WHILE condition: keep going while current byte was not 255
    ; (Sentinel logic makes termination explicit; still keeps do-while shape.)
    jmp     .do_body

.break_out:
    SYS_WRITE msg, msg_len
    mov     rdi, r12
    call    print_u64_ln
    SYS_EXIT 0

; print_u64_ln: unsigned in RDI + newline
print_u64_ln:
    lea     r8,  [outbuf + 31]
    mov     byte [r8], 10
    lea     rsi, [outbuf + 30]

    mov     rax, rdi
    cmp     rax, 0
    jne     .conv
    mov     byte [rsi], '0'
    mov     rdx, 2
    jmp     .emit

.conv:
    mov     rbx, 10
.loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    rax, rax
    jnz     .loop
    inc     rsi
    lea     rdx, [outbuf + 32]
    sub     rdx, rsi

.emit:
    SYS_WRITE rsi, rdx
    ret
