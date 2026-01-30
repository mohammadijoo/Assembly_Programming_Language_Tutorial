; Chapter 7 - Lesson 11 - Example 3
; Topic: Stack corruption detection using a custom canary (conceptual stack smashing signal)
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex3.asm -o ex3.o
;   gcc -no-pie ex3.o -o ex3
;
; Run:
;   ./ex3
;
; What it does:
;   - Calls guarded_fill with n=16 (safe).
;   - Calls guarded_fill with n=48 (overwrites past 32-byte buffer and corrupts canary).
;   - Canary mismatch triggers a controlled failure message and exit.

default rel
global main

section .data
msg0        db "== Stack canary demo (custom) ==", 10
msg0_len    equ $-msg0

msgSafe     db "Call 1: n=16 (within 32-byte buffer) returns OK", 10
msgSafe_len equ $-msgSafe

msgBad      db "Call 2: n=48 (beyond 32-byte buffer) returns should trip canary", 10
msgBad_len  equ $-msgBad

msgTrip     db "STACK CORRUPTION DETECTED: canary mismatch. Exiting.", 10
msgTrip_len equ $-msgTrip

msgOkRet    db "Returned normally (no corruption detected).", 10
msgOkRet_len equ $-msgOkRet

section .text

; write(1, rsi, rdx)
write1:
    mov eax, 1
    mov edi, 1
    syscall
    ret

sys_exit:
    mov eax, 60
    syscall

; guarded_fill(n in edi)
guarded_fill:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    ; canary = CONST xor rbp
    mov rax, 0x9e3779b97f4a7c15
    xor rax, rbp
    mov [rbp-32], rax

    ; fill buffer with 'C' for n bytes (intentional overflow if n  gt  32)
    lea rdi, [rbp-64]
    mov ecx, edi
    mov al, 'C'
    rep stosb

    ; verify canary
    mov rdx, [rbp-32]
    mov rax, 0x9e3779b97f4a7c15
    xor rax, rbp
    cmp rdx, rax
    jne .trip

    leave
    ret

.trip:
    lea rsi, [rel msgTrip]
    mov edx, msgTrip_len
    call write1
    mov edi, 3
    jmp sys_exit

main:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    lea rsi, [rel msgSafe]
    mov edx, msgSafe_len
    call write1
    mov edi, 16
    call guarded_fill
    lea rsi, [rel msgOkRet]
    mov edx, msgOkRet_len
    call write1

    lea rsi, [rel msgBad]
    mov edx, msgBad_len
    call write1
    mov edi, 48
    call guarded_fill

    xor edi, edi
    jmp sys_exit
