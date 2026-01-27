; Chapter 6 - Lesson 8 (Example 5)
; Saving callee-saved registers into explicit stack slots (instead of push/pop),
; while maintaining 16-byte alignment before a nested call.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: stack-slot save/restore preserved callee-saved regs", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL: callee-saved register corruption", 10
len_fail equ $-msg_fail

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

helper_clobber_volatiles:
    ; Allowed to clobber caller-saved regs
    mov rax, 0xAAAAAAAAAAAAAAAA
    mov rcx, 0xBBBBBBBBBBBBBBBB
    mov rdx, 0xCCCCCCCCCCCCCCCC
    ret

slot_saved_callee:
    ; Preserves RBX and R12 using explicit stack slots.
    ; Frame layout (40 bytes total for alignment):
    ;   [rsp+0]  = saved RBX
    ;   [rsp+8]  = saved R12
    ;   [rsp+16] = local scratch
    ;   [rsp+24] = padding
    ;   [rsp+32] = padding
    sub rsp, 40             ; entry: 16n+8, subtract 40 -> 16n aligned

    mov [rsp+0], rbx
    mov [rsp+8], r12

    ; modify callee-saved regs internally
    mov rbx, 0x1111111111111111
    mov r12, 0x2222222222222222

    call helper_clobber_volatiles

    ; restore
    mov rbx, [rsp+0]
    mov r12, [rsp+8]
    add rsp, 40
    ret

_start:
    mov rbx, 0x0123456789ABCDEF
    mov r12, 0x0F0E0D0C0B0A0908
    call slot_saved_callee

    cmp rbx, 0x0123456789ABCDEF
    jne .fail
    cmp r12, 0x0F0E0D0C0B0A0908
    jne .fail

    lea rsi, [rel msg_ok]
    mov edx, len_ok
    call write_msg
    mov eax, 60
    xor edi, edi
    syscall

.fail:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
    mov eax, 60
    mov edi, 1
    syscall
