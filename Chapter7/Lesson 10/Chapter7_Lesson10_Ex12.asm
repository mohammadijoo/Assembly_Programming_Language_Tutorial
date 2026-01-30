; Chapter7_Lesson10_Ex12.asm
; Topic: checked_read_u64: enforce bounds + alignment before 8-byte load
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
buf:        dq 0x1122334455667788, 0x99AABBCCDDEEFF00, 0x0102030405060708, 0x0
buf_len     equ $-buf

off_good    dq 8
off_bad     dq 10             ; unaligned

msg_ok      db "Aligned read OK.", 10
msg_ok_len  equ $-msg_ok
msg_bad     db "Rejected read (bounds or alignment).", 10
msg_bad_len equ $-msg_bad

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

; checked_read_u64(base=rdi, len=rsi, off=rdx) -> rax=value, rcx=0 ok / 1 fail
checked_read_u64:
    ; Alignment: off % 8 == 0
    test rdx, 7
    jnz .fail

    ; Bounds: off + 8 <= len
    mov r8, rdx
    add r8, 8
    jc .fail
    cmp r8, rsi
    ja .fail

    mov rax, [rdi + rdx]
    xor ecx, ecx
    ret
.fail:
    xor eax, eax
    mov ecx, 1
    ret

_start:
    lea rdi, [buf]
    mov rsi, buf_len
    mov rdx, [off_good]
    call checked_read_u64
    test ecx, ecx
    jne .bad
    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    lea rdi, [buf]
    mov rsi, buf_len
    mov rdx, [off_bad]
    call checked_read_u64
    test ecx, ecx
    je .bad_should_fail
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout

    xor edi, edi
    jmp exit_

.bad_should_fail:
.bad:
    mov edi, 1
    jmp exit_
