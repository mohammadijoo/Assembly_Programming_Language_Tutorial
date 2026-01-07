; Chapter 4 - Lesson 2 (Logical Instructions): Example 2
; Demonstrates flag-setting behavior and the difference between AND and TEST.
; AND writes the result back; TEST only updates flags.

BITS 64
DEFAULT REL

GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
msg1 db "Case 1: TEST rax,rax (does not modify rax)",10,0
len_msg1 equ $-msg1
msg2 db "  ZF=1 branch taken: rax was zero",10,0
len_msg2 equ $-msg2
msg3 db "  ZF=0 branch taken: rax was non-zero",10,0
len_msg3 equ $-msg3

msg4 db "Case 2: AND rax,rax (same flags as TEST, but writes back)",10,0
len_msg4 equ $-msg4

msg5 db "Case 3: AND rax,0 (forces rax=0, sets ZF=1)",10,0
len_msg5 equ $-msg5

msg6 db "  After AND rax,0: rax is now zero (value changed)",10,0
len_msg6 equ $-msg6

SECTION .text

write_stdout:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

_start:
    ; ----------------------------
    ; Case 1: TEST (flags only)
    ; ----------------------------
    lea rsi, [msg1]
    mov rdx, len_msg1
    call write_stdout

    mov rax, 0x1234
    test rax, rax
    jz .test_zero
    lea rsi, [msg3]
    mov rdx, len_msg3
    call write_stdout
    jmp .after_test
.test_zero:
    lea rsi, [msg2]
    mov rdx, len_msg2
    call write_stdout
.after_test:

    ; ----------------------------
    ; Case 2: AND rax,rax (writes back same value)
    ; ----------------------------
    lea rsi, [msg4]
    mov rdx, len_msg4
    call write_stdout

    mov rax, 0
    and rax, rax
    jz .and_zero
    lea rsi, [msg3]
    mov rdx, len_msg3
    call write_stdout
    jmp .after_and
.and_zero:
    lea rsi, [msg2]
    mov rdx, len_msg2
    call write_stdout
.after_and:

    ; ----------------------------
    ; Case 3: AND rax,0 (dest becomes 0)
    ; ----------------------------
    lea rsi, [msg5]
    mov rdx, len_msg5
    call write_stdout

    mov rax, 0xDEADBEEF
    and rax, 0
    jz .and_forced_zero
    jmp .done
.and_forced_zero:
    lea rsi, [msg6]
    mov rdx, len_msg6
    call write_stdout

.done:
    mov rax, SYS_exit
    xor rdi, rdi
    syscall
