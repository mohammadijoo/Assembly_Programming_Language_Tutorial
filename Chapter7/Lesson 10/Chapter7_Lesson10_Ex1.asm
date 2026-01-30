; Chapter7_Lesson10_Ex1.asm
; Topic: Debug-style assertions and reusable bounds-check macros (NASM, x86-64 Linux)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; echo $?

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
msg_ok      db "Assertions passed.", 10
msg_ok_len  equ $-msg_ok
msg_fail    db "ASSERTION FAILED", 10
msg_fail_len equ $-msg_fail

; -----------------------------
; "Header-like" macros
; -----------------------------

; ASSERT_JCC <cc>, <exit_code>
; Uses a conditional jump (j<cc>) based on flags set by the previous instruction.
; Example:
;   cmp rax, rbx
;   ASSERT_JCC b, 2      ; assert (rax < rbx) in *unsigned* sense
%macro ASSERT_JCC 2
    j%1 %%ok
    mov edi, %2
    jmp assert_fail
%%ok:
%endmacro

; CHECK_BOUNDS_U64 <index_reg>, <len_reg>, <exit_code>
; Asserts 0 <= index < len in unsigned arithmetic. (Caller ensures "index" is non-negative.)
%macro CHECK_BOUNDS_U64 3
    cmp %1, %2
    ASSERT_JCC b, %3     ; "b" means CF=1 => index < len (unsigned)
%endmacro

section .text
global _start

write_stdout:
    ; rsi=buf, rdx=len
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

assert_fail:
    lea rsi, [msg_fail]
    mov edx, msg_fail_len
    call write_stdout
    mov eax, SYS_exit
    syscall

_start:
    ; Demo: check that idx < len, and that an arithmetic invariant holds.

    mov r12, 10              ; len
    mov r13, 9               ; idx (in-range)
    CHECK_BOUNDS_U64 r13, r12, 22

    ; Another assertion: (5 + 7) == 12
    mov eax, 5
    add eax, 7
    cmp eax, 12
    ASSERT_JCC e, 23         ; "e" => ZF=1

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    xor edi, edi
    mov eax, SYS_exit
    syscall
