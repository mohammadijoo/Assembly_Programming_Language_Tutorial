; Chapter7_Lesson7_Ex6.asm
; Stack probing pattern: reserve N bytes and touch one byte per 4096-byte page.
; This is conceptually similar to what Windows _chkstk does to ensure guard pages are hit
; and to avoid "jumping over" an unmapped/guard page when allocating large frames.
;
; This sample uses the REAL machine stack (RSP). Keep N small-ish in experiments.

%define SYS_exit   60
%define SYS_write  1

global _start

section .rodata
msg_ok:     db "probed OK", 10
msg_ok_len: equ $-msg_ok

section .text

_start:
    ; Reserve ~3 pages + 64 bytes
    mov     rdi, 3*4096 + 64
    call    reserve_and_probe

    ; Print confirmation
    mov     rdi, 1              ; fd=stdout
    mov     rsi, msg_ok
    mov     rdx, msg_ok_len
    mov     eax, SYS_write
    syscall

    ; Release the reserved space
    mov     rsp, rax            ; rax returned original RSP
    xor     edi, edi
    mov     eax, SYS_exit
    syscall

; reserve_and_probe(rdi = bytes) -> rax = original_rsp
reserve_and_probe:
    mov     rax, rsp            ; save original
    mov     rcx, rdi            ; rcx = bytes

    ; Round up to 16 for ABI neatness (not strictly required for syscall-only demo)
    add     rcx, 15
    and     rcx, -16

    ; Probe in 4096 chunks
    mov     r8, 4096

.loop_pages:
    cmp     rcx, r8
    jb      .tail
    sub     rsp, r8
    ; Touch a byte in the newly allocated page
    mov     byte [rsp], 0
    sub     rcx, r8
    jmp     .loop_pages

.tail:
    test    rcx, rcx
    jz      .done
    sub     rsp, rcx
    mov     byte [rsp], 0

.done:
    ret
