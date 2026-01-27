; Chapter 6 - Lesson 11, Exercise 5 (with solution)
; File: Chapter6_Lesson11_Ex12.asm
; Topic: Frame-pointer chain and walking it (debug/unwind intuition)
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
; Run:
;   ./ex12 ; exit code should be 3 (we will walk 3 frames: funcC, funcB, funcA)

global _start

section .bss
frames resq 8

section .text

; uint64_t walk_rbp_chain(uint64_t* out, uint64_t max)
; out in RDI, max in RSI, returns count in RAX
walk_rbp_chain:
    push rbp
    mov rbp, rsp

    xor rax, rax           ; count = 0
    mov rdx, [rbp]         ; start from caller's saved RBP (chain head)

.loop:
    test rdx, rdx
    jz .done
    cmp rax, rsi
    jae .done

    ; store current frame base (saved rbp value)
    mov [rdi + rax*8], rdx
    inc rax

    ; next frame: load saved RBP at [rdx]
    mov rdx, [rdx]
    jmp .loop

.done:
    pop rbp
    ret

funcC:
    push rbp
    mov rbp, rsp
    ; walk 3 frames into frames[]
    lea rdi, [frames]
    mov rsi, 3
    call walk_rbp_chain
    pop rbp
    ret

funcB:
    push rbp
    mov rbp, rsp
    call funcC
    pop rbp
    ret

funcA:
    push rbp
    mov rbp, rsp
    call funcB
    pop rbp
    ret

_start:
    call funcA

    ; frames[] should have 3 non-zero entries if chain exists.
    lea rbx, [frames]
    xor ecx, ecx
.check:
    cmp ecx, 3
    je .ok
    mov rax, [rbx + rcx*8]
    test rax, rax
    jz .fail
    inc ecx
    jmp .check

.ok:
    mov edi, 3
    mov eax, 60
    syscall

.fail:
    mov edi, 1
    mov eax, 60
    syscall
