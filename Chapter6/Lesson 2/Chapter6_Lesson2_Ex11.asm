; Chapter 6 - Lesson 2 - Exercise Solution 3
; File: Chapter6_Lesson2_Ex11.asm
; Topic: Higher-order procedure: map_u64 with function pointer callback
;
; Signature:
;   void asm_map_u64(uint64_t (*f)(uint64_t), const uint64_t* in, uint64_t n, uint64_t* out)
;
; SysV args:
;   RDI = f
;   RSI = in
;   RDX = n
;   RCX = out
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11 ; exit 0 if tests pass

default rel
%include "Chapter6_Lesson2_Ex8.asm"

section .data
in_arr:  dq 1, 2, 3, 4, 5
out_arr: dq 0, 0, 0, 0, 0
exp_arr: dq 1, 4, 9, 16, 25

section .text
global _start
global asm_map_u64

square_u64:
    ; RDI = x
    mov rax, rdi
    imul rax, rdi
    ret

asm_map_u64:
    push rbx
    mov rbx, rdi     ; f ptr (callee-saved)

    xor r8d, r8d     ; i=0
.loop:
    cmp r8, rdx
    jae .done

    mov rdi, [rsi + r8*8]   ; arg to f
    call rbx                ; RAX = f(x)
    mov [rcx + r8*8], rax

    inc r8
    jmp .loop

.done:
    pop rbx
    ret

memcmp_u64:
    ; RDI=a, RSI=b, RDX=n (elements)
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jae .eq
    mov rax, [rdi + rcx*8]
    cmp rax, [rsi + rcx*8]
    jne .ne
    inc rcx
    jmp .loop
.eq:
    xor eax, eax
    ret
.ne:
    mov eax, 1
    ret

_start:
    lea rdi, [rel square_u64]
    lea rsi, [rel in_arr]
    mov edx, 5
    lea rcx, [rel out_arr]
    call asm_map_u64

    lea rdi, [rel out_arr]
    lea rsi, [rel exp_arr]
    mov edx, 5
    call memcmp_u64
    test eax, eax
    jne .fail

    SYS_EXIT 0
.fail:
    SYS_EXIT 1
