; Chapter6_Lesson1_Ex11.asm
; Exercise Solution (Hard): A callee-saved register contract harness.
; We create a "bad" callee that clobbers RBX and R12-R15 without restoring.
; Then we build a wrapper safe_call that saves/restores these regs around calling a function pointer.
;
; Goal: demonstrate that the *contract* is what keeps large programs correct.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex11.asm -o ex11.o
;   ld ex11.o -o ex11

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; int bad_callee(int x)
; returns x+1 but violates ABI by clobbering non-volatile regs.
bad_callee:
    mov rbx, 0x1111111111111111
    mov r12, 0x2222222222222222
    mov r13, 0x3333333333333333
    mov r14, 0x4444444444444444
    mov r15, 0x5555555555555555
    lea eax, [edi + 1]
    ret

; int safe_call(int (*fn)(int), int x)
; args: RDI=fn, ESI=x
; return: EAX
safe_call:
    push rbp
    mov rbp, rsp

    ; Save non-volatile regs (SysV): RBX, R12-R15 (RBP handled by frame)
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Call fn(x)
    mov rax, rdi               ; fn ptr
    mov edi, esi               ; x
    call rax

    ; Restore
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    leave
    ret

_start:
    ; Initialize non-volatile regs with "canary" values
    mov rbx, 0xAAAAAAAAAAAAAAAA
    mov r12, 0xBBBBBBBBBBBBBBBB
    mov r13, 0xCCCCCCCCCCCCCCCC
    mov r14, 0xDDDDDDDDDDDDDDDD
    mov r15, 0xEEEEEEEEEEEEEEEE

    ; Call bad_callee directly -> registers will be corrupted
    mov edi, 41
    call bad_callee

    ; Check corruption happened (expect RBX != 0xAAAAAAAA...)
    mov rax, 0xAAAAAAAAAAAAAAAA
    cmp rbx, rax
    je .fail_direct_not_corrupted

    ; Reinitialize canaries
    mov rbx, 0xAAAAAAAAAAAAAAAA
    mov r12, 0xBBBBBBBBBBBBBBBB
    mov r13, 0xCCCCCCCCCCCCCCCC
    mov r14, 0xDDDDDDDDDDDDDDDD
    mov r15, 0xEEEEEEEEEEEEEEEE

    ; Call through safe_call wrapper -> canaries must remain intact
    lea rdi, [rel bad_callee]
    mov esi, 41
    call safe_call             ; returns 42 in EAX

    ; Verify return value and canaries
    cmp eax, 42
    jne .fail

    mov rax, 0xAAAAAAAAAAAAAAAA
    cmp rbx, rax
    jne .fail
    mov rax, 0xBBBBBBBBBBBBBBBB
    cmp r12, rax
    jne .fail
    mov rax, 0xCCCCCCCCCCCCCCCC
    cmp r13, rax
    jne .fail
    mov rax, 0xDDDDDDDDDDDDDDDD
    cmp r14, rax
    jne .fail
    mov rax, 0xEEEEEEEEEEEEEEEE
    cmp r15, rax
    jne .fail

    xor edi, edi
    mov eax, 60
    syscall

.fail_direct_not_corrupted:
.fail:
    mov edi, 1
    mov eax, 60
    syscall
