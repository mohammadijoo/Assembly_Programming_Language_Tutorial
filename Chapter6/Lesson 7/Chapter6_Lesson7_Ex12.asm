; Chapter 6 - Lesson 7 - Exercise 5 (Solution)
; Title: 32-byte stack realignment wrapper (for AVX-friendly locals) + safe restore
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;
; Notes:
;   - SysV ABI requires 16-byte alignment at call-sites.
;   - Some AVX code prefers (not requires) 32-byte alignment for vmovaps ymm.
;   - This wrapper aligns the stack to 32 bytes for its callee and restores
;     original RSP on return.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    lea rdi, [avx_like_callee]
    call call_with_align32
    mov eax, 60
    xor edi, edi
    syscall

; ------------------------------------------------------------
; call_with_align32(target_ptr):
;   RDI = target function pointer (takes no args)
; Ensures:
;   - Inside the wrapper, stack is aligned to 32 for local spills
;   - At the actual CALL instruction, RSP is 16-aligned (also 32-aligned)
; Restores original RSP before returning.
call_with_align32:
    push rbp
    mov rbp, rsp

    ; Align down to 32 bytes.
    and rsp, -32

    ; Reserve local scratch (multiple of 32 keeps alignment)
    sub rsp, 64

    call rdi

    mov rsp, rbp
    pop rbp
    ret

; ------------------------------------------------------------
; avx_like_callee:
; Demonstrates a 32-byte aligned local area usage.
; (No AVX instructions required to validate the alignment logic.)
avx_like_callee:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; We could safely use [rsp] as 16-aligned; with wrapper it's also 32-aligned.
    ; Placeholder work:
    mov qword [rsp], 0x123456789ABCDEF0
    mov rax, [rsp]

    add rsp, 32
    pop rbp
    ret
