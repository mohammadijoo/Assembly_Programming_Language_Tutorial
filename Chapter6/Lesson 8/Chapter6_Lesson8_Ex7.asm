; Chapter 6 - Lesson 8 (Example 7)
; ABI guard: a tiny unit test that validates callee-saved preservation for RBX and R12.
; This is a practical discipline for assembly APIs: keep a regression test for your ABI contract.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7

BITS 64
default rel
global _start

section .rodata
msg_bad db "OK: caught ABI violation (callee clobbered RBX/R12)", 10
len_bad equ $-msg_bad
msg_good db "OK: callee preserved RBX/R12", 10
len_good equ $-msg_good
msg_fail db "FAIL: ABI guard logic error", 10
len_fail equ $-msg_fail

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

target_bad:
    ; Violates ABI by clobbering callee-saved regs.
    xor rbx, rbx
    xor r12, r12
    ret

target_good:
    push rbx
    push r12
    mov rbx, 7
    mov r12, 9
    pop r12
    pop rbx
    ret

abi_guard_rbx_r12:
    ; rdi = pointer to function to test
    push rbx
    push r12
    sub rsp, 8               ; align for indirect call

    mov rbx, 0x1111222233334444
    mov r12, 0xAAAABBBBCCCCDDDD

    call rdi                 ; may clobber caller-saved regs; must preserve callee-saved

    cmp rbx, 0x1111222233334444
    jne .viol
    cmp r12, 0xAAAABBBBCCCCDDDD
    jne .viol

    xor eax, eax             ; return 0 = preserved
    jmp .out
.viol:
    mov eax, 1               ; return 1 = violated
.out:
    add rsp, 8
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [rel target_bad]
    call abi_guard_rbx_r12
    cmp eax, 1
    jne .fail
    lea rsi, [rel msg_bad]
    mov edx, len_bad
    call write_msg

    lea rdi, [rel target_good]
    call abi_guard_rbx_rbx_r12_fix

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

; A small fix: demonstrate that "discipline" includes carefully reviewing your own guard code.
abi_guard_rbx_rbx_r12_fix:
    ; same as abi_guard_rbx_r12 but called second, to keep control flow simple
    ; rdi = pointer to function
    push rbx
    push r12
    sub rsp, 8

    mov rbx, 0x1111222233334444
    mov r12, 0xAAAABBBBCCCCDDDD
    call rdi

    cmp rbx, 0x1111222233334444
    jne .viol
    cmp r12, 0xAAAABBBBCCCCDDDD
    jne .viol

    lea rsi, [rel msg_good]
    mov edx, len_good
    call write_msg
    jmp .out
.viol:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
.out:
    add rsp, 8
    pop r12
    pop rbx
    ret
