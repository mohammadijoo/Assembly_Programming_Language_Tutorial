; Chapter 4 - Lesson 6 (Stack Operations) - Example 6
; NASM macros for disciplined register save/restore using PUSH/POP.

default rel
global _start

%macro PUSH_CALLEE_SAVED 0
    ; SysV AMD64 callee-saved: RBX, RBP, R12-R15 (RBP handled separately when used as frame pointer)
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro POP_CALLEE_SAVED 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

section .data
hex_digits: db "0123456789ABCDEF"
hex_buf:    db "0x", 16 dup("0"), 10

section .text
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

to_hex64:
    push rbx
    lea rbx, [hex_digits]
    mov rcx, 16
.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx + rdx]
    mov [rdi + rcx - 1], dl
    shr rax, 4
    loop .hex_loop
    pop rbx
    ret

print_hex64:
    sub rsp, 8
    lea rdi, [hex_buf + 2]
    call to_hex64
    lea rsi, [hex_buf]
    mov edx, 19
    call write_stdout
    add rsp, 8
    ret

clobber_but_restore:
    ; Demonstrate "push-save / clobber / pop-restore"
    PUSH_CALLEE_SAVED

    mov rbx, 0x1111111111111111
    mov r12, 0x2222222222222222
    mov r13, 0x3333333333333333
    mov r14, 0x4444444444444444
    mov r15, 0x5555555555555555

    POP_CALLEE_SAVED
    ret

_start:
    ; Seed callee-saved with known values, call function that clobbers them but restores.
    mov rbx, 0xAAAAAAAAAAAAAAAA
    mov r12, 0xBBBBBBBBBBBBBBBB
    mov r13, 0xCCCCCCCCCCCCCCCC
    mov r14, 0xDDDDDDDDDDDDDDDD
    mov r15, 0xEEEEEEEEEEEEEEEE

    ; Keep ABI alignment: we are at RSP%16=0 here, and clobber_but_restore uses no CALLs.
    call clobber_but_restore

    ; Verify values survived.
    mov rax, rbx
    call print_hex64
    mov rax, r12
    call print_hex64
    mov rax, r13
    call print_hex64
    mov rax, r14
    call print_hex64
    mov rax, r15
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
