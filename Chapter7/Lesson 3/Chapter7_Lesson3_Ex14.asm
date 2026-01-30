; Chapter 7 - Lesson 3 - Example 14 (Exercise Solution 4)
; Implementing a tiny "malloc stats" sampler: allocate K blocks, touch them, free them
; This is a stress-pattern harness used to evaluate allocator behavior (fragmentation-ish).
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex14.asm -o ex14.o
;   gcc -no-pie ex14.o -o ex14

default rel
global main
extern malloc
extern free
extern printf

%define K 256

section .bss
ptrs resq K

section .data
fmt db "allocated and freed %d blocks of %d bytes", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8

    ; allocate K blocks of 128 bytes
    xor  ebx, ebx
.alloc_loop:
    cmp  ebx, K
    jge  .touch
    mov  edi, 128
    call malloc
    test rax, rax
    jz   .oom
    mov  [ptrs + rbx*8], rax
    inc  ebx
    jmp  .alloc_loop

.touch:
    ; touch first qword of each block (forces page mapping)
    xor  ebx, ebx
.touch_loop:
    cmp  ebx, K
    jge  .free
    mov  rax, [ptrs + rbx*8]
    mov  qword [rax], 0x1122334455667788
    inc  ebx
    jmp  .touch_loop

.free:
    xor  ebx, ebx
.free_loop:
    cmp  ebx, K
    jge  .report
    mov  rdi, [ptrs + rbx*8]
    call free
    inc  ebx
    jmp  .free_loop

.report:
    lea  rdi, [fmt]
    mov  esi, K
    mov  edx, 128
    xor  eax, eax
    call printf

    xor  eax, eax
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

.oom:
    ; free what we already allocated
    dec  ebx
.free_partial:
    cmp  ebx, -1
    jle  .fail
    mov  rdi, [ptrs + rbx*8]
    call free
    dec  ebx
    jmp  .free_partial

.fail:
    mov  eax, 1
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret
