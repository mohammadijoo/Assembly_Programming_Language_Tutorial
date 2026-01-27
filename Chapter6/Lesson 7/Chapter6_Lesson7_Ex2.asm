; Chapter 6 - Lesson 7 - Example 2
; Title: Dynamic stack realignment wrapper (SysV), safe even if caller misaligns
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .rodata
msg_before: db "Calling target with a deliberately misaligned stack (via wrapper)...", 10
len_before: equ $-msg_before
msg_after:  db "Returned successfully (wrapper restored original RSP).", 10
len_after:  equ $-msg_after

SECTION .text

write_str:
    mov eax, 1
    mov edi, 1
    syscall
    ret

_start:
    lea rsi, [msg_before]
    mov edx, len_before
    call write_str

    ; Deliberately violate ABI: make RSP misaligned before a call.
    ; This simulates "foreign" code, hand-written asm bugs, or stack corruption.
    sub rsp, 8

    ; Call wrapper with target address in RDI
    lea rdi, [target_requires_alignment]
    call call_with_align16

    ; Restore the artificial misalignment we created.
    add rsp, 8

    lea rsi, [msg_after]
    mov edx, len_after
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; ------------------------------------------------------------
; call_with_align16(target_ptr):
;   RDI = target function pointer (takes no args)
; Guarantees: at the indirect CALL, RSP % 16 == 0 (call-site aligned)
; Preserves: original stack pointer on return (even if incoming was misaligned)
call_with_align16:
    push rbp
    mov rbp, rsp

    ; Align downward to a 16-byte boundary
    and rsp, -16

    ; Optional scratch space (also keeps alignment)
    sub rsp, 32

    call rdi

    mov rsp, rbp
    pop rbp
    ret

; ------------------------------------------------------------
; target_requires_alignment:
; Uses MOVAPS on [rsp], so it MUST see aligned stack after its own prologue.
target_requires_alignment:
    push rbp
    mov rbp, rsp
    sub rsp, 16              ; ensures [rsp] is 16-aligned

    pxor xmm0, xmm0
    movaps [rsp], xmm0       ; would fault if unaligned
    movaps xmm1, [rsp]

    add rsp, 16
    pop rbp
    ret
