; Chapter 6 - Lesson 7 - Example 1
; Title: SysV stack alignment probe (Linux x86-64, syscall-only)
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .rodata
msg_entry_ok:     db "Entry alignment: RSP%16 == 8 (OK)", 10
msg_entry_ok_len: equ $-msg_entry_ok
msg_entry_bad:    db "Entry alignment: RSP%16 != 8 (BAD)", 10
msg_entry_bad_len: equ $-msg_entry_bad

msg_pro_ok:       db "After prologue: RSP%16 == 0 (OK for call-site)", 10
msg_pro_ok_len:   equ $-msg_pro_ok
msg_pro_bad:      db "After prologue: RSP%16 != 0 (BAD for call-site)", 10
msg_pro_bad_len:  equ $-msg_pro_bad

msg_sse_ok:       db "SSE spill demo executed (movaps on aligned stack)", 10
msg_sse_ok_len:   equ $-msg_sse_ok

SECTION .text

_start:
    ; Linux places RSP 16-byte aligned at process entry for _start.
    call alignment_probe

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

; -----------------------------------------
; write_str: write(1, rsi, rdx)
; clobbers: rax, rdi, rcx, r11
write_str:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; -----------------------------------------
; alignment_probe: called by _start
; Demonstrates:
;   - ABI entry alignment (after CALL pushes return address)
;   - How to keep call-site alignment after prologue/local allocation
alignment_probe:
    ; At callee entry (after CALL), SysV expects: RSP % 16 == 8
    mov rax, rsp
    and rax, 15
    cmp rax, 8
    jne .entry_bad
.entry_ok:
    lea rsi, [msg_entry_ok]
    mov edx, msg_entry_ok_len
    call write_str
    jmp .prologue

.entry_bad:
    lea rsi, [msg_entry_bad]
    mov edx, msg_entry_bad_len
    call write_str

.prologue:
    ; Standard frame + locals, keeping 16B alignment at call-sites:
    ; Entry:   RSP = 16n + 8
    ; push rbp => RSP = 16n
    ; sub rsp, 32 => still 16-byte aligned
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Now at THIS point (before any CALL), we want: RSP % 16 == 0
    mov rax, rsp
    and rax, 15
    test rax, rax
    jne .pro_bad
.pro_ok:
    lea rsi, [msg_pro_ok]
    mov edx, msg_pro_ok_len
    call write_str
    jmp .call_demo

.pro_bad:
    lea rsi, [msg_pro_bad]
    mov edx, msg_pro_bad_len
    call write_str

.call_demo:
    ; Call a helper that uses MOVAPS to spill to the stack.
    call sse_spill_demo

    lea rsi, [msg_sse_ok]
    mov edx, msg_sse_ok_len
    call write_str

    add rsp, 32
    pop rbp
    ret

; -----------------------------------------
; sse_spill_demo:
; Uses MOVAPS to/from [rsp], which requires 16-byte alignment.
; This routine aligns its own stack by a standard push+sub pattern.
sse_spill_demo:
    push rbp
    mov rbp, rsp

    ; Entry: RSP%16 == 8
    ; push rbp => aligned
    ; sub 16 => still aligned
    sub rsp, 16

    pxor xmm0, xmm0
    movaps [rsp], xmm0
    movaps xmm1, [rsp]

    add rsp, 16
    pop rbp
    ret
