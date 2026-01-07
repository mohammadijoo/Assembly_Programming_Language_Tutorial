; Chapter 2 - Lesson 10 - Example 7
; Using symbolic offsets to make LEA/MOV addressing robust (struct-like layout)
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex7.asm -o ex7.o && ld ex7.o -o ex7 && ./ex7 ; echo $?

global _start

; "Struct" layout (manual offsets)
%define NODE_x      0   ; int32
%define NODE_y      4   ; int32
%define NODE_z      8   ; int64
%define NODE_size  16

section .data
    ; Two nodes back-to-back: {x,y,z} with 16-byte stride
    nodes:
        dd  1, 2
        dq  100
        dd  3, 4
        dq  200

section .text
_start:
    ; Pointer to nodes[0]
    lea rdi, [rel nodes]

    ; Address-of nodes[1].z = base + 1*NODE_size + NODE_z
    lea rbx, [rdi + NODE_size + NODE_z]
    mov rax, [rbx]            ; rax = 200

    ; Swap x and y in nodes[1] using MOV + XCHG-with-mem idiom:
    ;   eax = x
    ;   x <-> y
    ;   x = old y
    lea rcx, [rdi + NODE_size]
    mov eax, dword [rcx + NODE_x]
    xchg eax, dword [rcx + NODE_y]
    mov dword [rcx + NODE_x], eax

    ; After swap nodes[1] should be x=4, y=3
    xor edi, edi
    cmp dword [rcx + NODE_x], 4
    je .ok1
    or edi, 1
.ok1:
    cmp dword [rcx + NODE_y], 3
    je .ok2
    or edi, 2
.ok2:
    cmp rax, 200
    je .ok3
    or edi, 4
.ok3:
    mov eax, 60
    syscall
