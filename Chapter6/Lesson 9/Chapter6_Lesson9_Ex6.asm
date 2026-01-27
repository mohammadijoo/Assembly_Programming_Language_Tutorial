; Chapter6_Lesson9_Ex6.asm
; A tiny ABI abstraction pattern for "sret" (hidden return pointer) functions.
;
; This file is written to assemble under NASM for either:
;   - SysV AMD64 (Linux/macOS): sret pointer is the first integer arg in RDI
;   - Microsoft x64 (Windows): sret pointer is the first integer arg in RCX
;
; Enable Windows-style registers by defining WIN64:
;   nasm -DWIN64 -fwin64 Chapter6_Lesson9_Ex6.asm
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

global _start

section .text

; --- Register mapping for a 24-byte return object + three 64-bit inputs ---
%ifdef WIN64
    %define OUT  rcx
    %define A0   rdx
    %define A1   r8
    %define A2   r9
%else
    %define OUT  rdi
    %define A0   rsi
    %define A1   rdx
    %define A2   rcx
%endif

make_3q:
    ; void make_3q(struct {u64 x,y,z}* out, u64 a0, u64 a1, u64 a2)
    mov     [OUT + 0],  A0
    mov     [OUT + 8],  A1
    mov     [OUT + 16], A2
    mov     rax, OUT            ; common convention: return the sret pointer
    ret

_start:
    sub     rsp, 32
    lea     OUT, [rsp]

%ifdef WIN64
    mov     rdx, 11
    mov     r8,  22
    mov     r9,  33
%else
    mov     rsi, 11
    mov     rdx, 22
    mov     rcx, 33
%endif

    call    make_3q

    cmp     qword [rsp + 0], 11
    jne     .fail
    cmp     qword [rsp + 8], 22
    jne     .fail
    cmp     qword [rsp + 16], 33
    jne     .fail

.ok:
    add     rsp, 32
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    add     rsp, 32
    mov     eax, 60
    mov     edi, 1
    syscall
