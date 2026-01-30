; Chapter7_Lesson10_Ex2.asm
; Topic: Basic bounds-checked array access (unsigned compare + explicit negative reject)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
arr        db 10, 20, 30, 40, 50, 60
arr_len    equ $-arr

idx        dd 4               ; change to -1 or 6 to see rejection

msg_ok     db "Read OK (index in range).", 10
msg_ok_len equ $-msg_ok
msg_oob    db "Rejected (index out of range).", 10
msg_oob_len equ $-msg_oob

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

_start:
    mov eax, [idx]            ; signed 32-bit index
    test eax, eax
    js .oob                   ; reject negative explicitly

    mov ecx, arr_len
    cmp eax, ecx
    jae .oob                  ; idx >= len (unsigned) => out of bounds

    ; Safe: idx in [0, len)
    movzx eax, byte [arr + rax]

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    xor edi, edi
    jmp exit_

.oob:
    lea rsi, [msg_oob]
    mov edx, msg_oob_len
    call write_stdout
    mov edi, 1
    jmp exit_
