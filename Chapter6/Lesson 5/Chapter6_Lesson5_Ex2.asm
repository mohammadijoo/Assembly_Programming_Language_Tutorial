bits 64
default rel
global _start

; Inlining in NASM often means "macro expansion" (textual), not a linker trick.
%macro ADD_U64 2
    add %1, %2
%endmacro

section .text
_start:
    ; Compute sum_{i=1..N} i two ways:
    ;   (1) calling a tiny function each iteration
    ;   (2) inlining the add via macro (no call/ret)

    mov r8d, 1000

    ; (1) call-based
    xor eax, eax              ; sum1 in RAX
    mov ecx, 1
.loop_call:
    mov rdi, rax              ; arg0 = sum
    mov rsi, rcx              ; arg1 = i
    call add_u64              ; RAX = sum + i
    inc ecx
    cmp ecx, r8d
    jle .loop_call

    ; (2) inline-based
    xor ebx, ebx              ; sum2 in RBX
    mov ecx, 1
.loop_inline:
    ADD_U64 rbx, rcx
    inc ecx
    cmp ecx, r8d
    jle .loop_inline

    ; Verify equality
    cmp rax, rbx
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; add_u64(x,y) = x+y
add_u64:
    lea rax, [rdi + rsi]
    ret
