; Chapter 6 - Lesson 8 (Example 9)
; Using NASM macros for disciplined saving/restoring of callee-saved registers.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9

BITS 64
default rel
global _start

%include "Chapter6_Lesson8_Ex8.asm"

section .rodata
msg_ok   db "OK: sum verified and ABI saves are correct", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL: sum mismatch", 10
len_fail equ $-msg_fail

section .data
buf db 1,2,3,4,5,6,7,8

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

load_u8:
    ; rdi = address
    ; returns eax = zero-extended byte value
    movzx eax, byte [rdi]
    ret

sum_bytes_with_calls:
    ; rdi = ptr, rsi = len
    ; returns rax = sum (64-bit)
    ; Uses RBX (index) and R12 (base pointer): callee-saved -> preserve.
    ; Calls load_u8 in the loop -> ensure 16B alignment before CALL.
    PUSH_LIST rbx, r12              ; 2 pushes
    SYSV_ALIGN_FOR_CALL 2           ; aligned for SysV

    mov r12, rdi
    xor ebx, ebx
    xor eax, eax                    ; sum in EAX (we will widen carefully)

.loop:
    cmp rbx, rsi
    jae .done

    lea rdi, [r12 + rbx]
    call load_u8                    ; eax = byte (0..255)
    add dword [rel sum_scratch], eax ; accumulate in memory to avoid partial-register issues

    inc rbx
    jmp .loop

.done:
    mov eax, [rel sum_scratch]
    mov dword [rel sum_scratch], 0

    SYSV_UNALIGN_AFTER_CALL 2
    POP_LIST rbx, r12
    ret

section .bss
sum_scratch resd 1

_start:
    lea rdi, [rel buf]
    mov rsi, 8
    call sum_bytes_with_calls

    cmp rax, 36                 ; 1+2+...+8 = 36
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
