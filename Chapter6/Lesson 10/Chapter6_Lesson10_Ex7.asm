; Chapter 6 - Lesson 10 (Ex7): Windows x64 - Implementing an integer-only variadic function
; Signature (C view): long long sum_ints_win(long long count, ...);
; Varargs are assumed to be 64-bit integers.
;
; Build (Windows x64, one possible workflow):
;   nasm -f win64 Chapter6_Lesson10_Ex7.asm -o ex7.obj
;   link /subsystem:console ex7.obj msvcrt.lib kernel32.lib
;
; Note: This file is intended for Windows; it won't link on Linux.

default rel
bits 64

extern printf
extern ExitProcess
global main
global sum_ints_win

section .rdata
fmt: db "sum_ints_win(%lld, ...) = %lld", 13,10,0

section .text
; long long sum_ints_win(long long count, ...);
; RCX = count, varargs start at RDX, R8, R9, then stack.
sum_ints_win:
    push rbp
    mov rbp, rsp

    ; Home the register varargs into their shadow/home slots
    ; After PUSH RBP:
    ;   [rbp+8]  = return address
    ;   [rbp+16] = home for RCX (param1)
    ;   [rbp+24] = home for RDX (param2)
    ;   [rbp+32] = home for R8  (param3)
    ;   [rbp+40] = home for R9  (param4)
    mov [rbp+24], rdx
    mov [rbp+32], r8
    mov [rbp+40], r9

    xor rax, rax                 ; sum
    xor r10d, r10d               ; i = 0

.loop:
    cmp r10, rcx
    jae .done

    cmp r10, 3
    jb .from_home

    ; stack varargs beyond the first three register varargs:
    ; param5 starts at [rbp+48]
    mov r11, r10
    sub r11, 3
    mov rdx, [rbp + 48 + r11*8]
    jmp .add

.from_home:
    mov rdx, [rbp + 24 + r10*8]

.add:
    add rax, rdx
    inc r10
    jmp .loop

.done:
    pop rbp
    ret

main:
    sub rsp, 28h                 ; shadow + alignment

    ; Call sum_ints_win(8, 1,2,3,4,5,6,7,8)
    ; RCX=count, RDX,R8,R9 hold first 3 varargs, remaining on stack after shadow space.
    mov rcx, 8
    mov rdx, 1
    mov r8,  2
    mov r9,  3

    ; stack args (4..8): placed after 32B shadow space, right-to-left is not required by ABI,
    ; but memory order must match argument positions.
    mov qword [rsp + 20h], 4
    mov qword [rsp + 28h], 5
    mov qword [rsp + 30h], 6
    mov qword [rsp + 38h], 7
    mov qword [rsp + 40h], 8

    call sum_ints_win            ; RAX = result

    ; printf(fmt, count, result)
    lea rcx, [fmt]
    mov rdx, 8
    mov r8,  rax
    call printf

    xor ecx, ecx
    call ExitProcess
