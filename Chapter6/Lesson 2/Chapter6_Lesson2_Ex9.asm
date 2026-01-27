; Chapter 6 - Lesson 2 - Exercise Solution 1
; File: Chapter6_Lesson2_Ex9.asm
; Topic: memmove (overlap-safe) as a procedure + self-test harness
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
; Run:
;   ./ex9 ; exit 0 if tests pass

default rel
%include "Chapter6_Lesson2_Ex8.asm"

section .data
buf:      db "abcdefghij"         ; 10 bytes (no NUL needed)
expected: db "ababcdefgh"         ; after memmove(buf+2, buf, 8)

section .text
global _start
global asm_memmove

; asm_memmove(void* dst, const void* src, uint64_t n) -> RAX = dst
; SysV: RDI=dst, RSI=src, RDX=n
; Guarantees DF is cleared on return.
asm_memmove:
    mov rax, rdi
    test rdx, rdx
    jz .done

    cmp rdi, rsi
    je .done

    ; if dst &lt; src  => forward is safe
    cmp rdi, rsi
    jb .forward

    ; compute src_end = src + n
    lea rcx, [rsi + rdx]
    ; if dst &gt;= src_end => forward is safe (no overlap)
    cmp rdi, rcx
    jae .forward

    ; Overlap where dst &gt; src: copy backwards
    std
    lea rsi, [rsi + rdx - 1]
    lea rdi, [rdi + rdx - 1]
    mov rcx, rdx
    rep movsb
    cld
    jmp .done

.forward:
    cld
    mov rcx, rdx
    rep movsb
    ; DF already clear
.done:
    cld
    ret

; memcmp_u8(a,b,n) -> ZF=1 if equal, else ZF=0
; RDI=a, RSI=b, RDX=n
memcmp_u8:
    test rdx, rdx
    jz .eq
    xor rcx, rcx
.loop:
    mov al, [rdi + rcx]
    cmp al, [rsi + rcx]
    jne .ne
    inc rcx
    cmp rcx, rdx
    jb .loop
.eq:
    xor eax, eax
    ret
.ne:
    mov eax, 1
    ret

_start:
    ; Perform overlap memmove(buf+2, buf, 8)
    lea rdi, [rel buf + 2]
    lea rsi, [rel buf]
    mov edx, 8
    call asm_memmove

    ; Compare buf with expected (10 bytes)
    lea rdi, [rel buf]
    lea rsi, [rel expected]
    mov edx, 10
    call memcmp_u8
    test eax, eax
    jne .fail

    SYS_EXIT 0
.fail:
    SYS_EXIT 1
