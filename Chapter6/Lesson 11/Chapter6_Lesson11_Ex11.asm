; Chapter 6 - Lesson 11, Exercise 4 (with solution)
; File: Chapter6_Lesson11_Ex11.asm
; Topic: 7th integer argument passed on stack, alignment + access pattern
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11 ; exit code should be (1+2+3+4+5+6+7)=28

global _start

section .text

; int64_t callee7(a,b,c,d,e,f,g)
; a..f in regs: RDI, RSI, RDX, RCX, R8, R9
; g on stack at [RSP+8] on entry (because [RSP] is return address)
callee7:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rsp + 8]     ; g
    ret

; caller that demonstrates required alignment and stack arg placement
caller_call7:
    ; Entry: RSP % 16 == 8
    ; We need a 8-byte slot for arg7 and we want RSP % 16 == 0 before CALL.
    sub rsp, 8
    mov qword [rsp], 7      ; arg7

    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8,  5
    mov r9,  6
    call callee7

    add rsp, 8
    ret

_start:
    call caller_call7
    mov edi, eax
    mov eax, 60
    syscall
