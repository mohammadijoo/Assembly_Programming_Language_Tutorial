; Chapter 6 - Lesson 10 (Ex5): SysV AMD64 - Demonstrating the va_list algorithm with a synthetic frame
; We *construct*:
;   - a reg_save_area with 6 GP slots (rdi,rsi,rdx,rcx,r8,r9)
;   - an overflow_arg_area array for additional "stack" args
;   - a va_list-like struct with gp_offset starting after 1 named GP argument
; Then we repeatedly call sysv_va_arg_i64 to read 8 int64 values and print them.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex4.asm -o ex4.o
;   nasm -f elf64 Chapter6_Lesson10_Ex5.asm -o ex5.o
;   gcc -no-pie ex4.o ex5.o -o ex5
; Run:
;   ./ex5

default rel
bits 64

extern printf
extern sysv_va_arg_i64
global main

section .rodata
fmt: db "arg[%ld] = %ld", 10, 0

section .bss
align 16
reg_save_area:  resb 48         ; only GP part for this demo
overflow_area:  resq 16         ; fake "stack" args
va_obj:         resb 24         ; struct layout: u32,u32,ptr,ptr (with padding)

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Fill reg_save_area slots: rdi,rsi,rdx,rcx,r8,r9
    mov qword [reg_save_area + 0],  1111
    mov qword [reg_save_area + 8],  1
    mov qword [reg_save_area +16],  2
    mov qword [reg_save_area +24],  3
    mov qword [reg_save_area +32],  4
    mov qword [reg_save_area +40],  5

    ; Fill overflow_area with more args (6,7,8...)
    mov qword [overflow_area + 0], 6
    mov qword [overflow_area + 8], 7
    mov qword [overflow_area +16], 8
    mov qword [overflow_area +24], 9

    ; Build va_obj:
    ; gp_offset: skip 1 named GP arg => start at slot for RSI => 8 bytes
    mov dword [va_obj + 0], 8
    mov dword [va_obj + 4], 304        ; unused in this i64-only demo (set to "exhausted")
    lea rax, [overflow_area]
    mov [va_obj + 8], rax
    lea rax, [reg_save_area]
    mov [va_obj +16], rax

    xor r12d, r12d               ; i = 0
.loop:
    cmp r12d, 8
    jae .done

    lea rdi, [va_obj]
    call sysv_va_arg_i64          ; RAX = next int64

    ; printf(fmt, i, value)
    mov rdi, fmt
    mov rsi, r12
    mov rdx, rax
    xor eax, eax
    call printf

    inc r12d
    jmp .loop

.done:
    xor eax, eax
    leave
    ret
