; Chapter 7 - Lesson 3 - Example 15 (Exercise Solution 5)
; Pool allocator for variable-sized requests using segregated size classes (mini-slab)
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex15.asm -o ex15.o
;   gcc -no-pie ex15.o -o ex15
;
; This is a compact educational sketch:
;   - size classes: 32, 64, 128 bytes
;   - each class uses a free list built from a static arena
; Limitations:
;   - fixed total pool size, no coalescing, no OOM recovery besides NULL

default rel
global main
extern printf

%define CLS0 32
%define CLS1 64
%define CLS2 128

%define N0 64
%define N1 32
%define N2 16

section .bss
pool0 resb (CLS0*N0)
pool1 resb (CLS1*N1)
pool2 resb (CLS2*N2)
head0 resq 1
head1 resq 1
head2 resq 1

section .data
fmt db "class=%d alloc=%p", 10, 0

section .text
; build free list for a pool: base in RDI, block_size in RSI, count in RDX, head_ptr in RCX
init_class:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8

    mov  rbx, rdi              ; base
    mov  [rcx], rbx            ; head = base
    xor  r8d, r8d              ; i = 0
.loop:
    cmp  r8, rdx
    jge  .done

    lea  r9, [rbx + r8*rsi]    ; current
    inc  r8
    cmp  r8, rdx
    je   .last
    lea  r10, [rbx + r8*rsi]   ; next
    mov  [r9], r10
    jmp  .loop
.last:
    mov  qword [r9], 0
.done:
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

; void* slab_alloc(size)
; RDI=size
slab_alloc:
    cmp  rdi, CLS0
    jbe  .c0
    cmp  rdi, CLS1
    jbe  .c1
    cmp  rdi, CLS2
    jbe  .c2
    xor  rax, rax
    ret
.c0:
    mov  rax, [head0]
    test rax, rax
    jz   .none
    mov  rdx, [rax]
    mov  [head0], rdx
    ret
.c1:
    mov  rax, [head1]
    test rax, rax
    jz   .none
    mov  rdx, [rax]
    mov  [head1], rdx
    ret
.c2:
    mov  rax, [head2]
    test rax, rax
    jz   .none
    mov  rdx, [rax]
    mov  [head2], rdx
    ret
.none:
    xor  rax, rax
    ret

; void slab_free(ptr, size)
; RDI=ptr, RSI=size
slab_free:
    test rdi, rdi
    jz   .ret
    cmp  rsi, CLS0
    jbe  .f0
    cmp  rsi, CLS1
    jbe  .f1
    cmp  rsi, CLS2
    jbe  .f2
    ret
.f0:
    mov  rax, [head0]
    mov  [rdi], rax
    mov  [head0], rdi
    ret
.f1:
    mov  rax, [head1]
    mov  [rdi], rax
    mov  [head1], rdi
    ret
.f2:
    mov  rax, [head2]
    mov  [rdi], rax
    mov  [head2], rdi
.ret:
    ret

main:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    sub  rsp, 8

    ; init each class
    lea  rdi, [pool0]
    mov  rsi, CLS0
    mov  rdx, N0
    lea  rcx, [head0]
    call init_class

    lea  rdi, [pool1]
    mov  rsi, CLS1
    mov  rdx, N1
    lea  rcx, [head1]
    call init_class

    lea  rdi, [pool2]
    mov  rsi, CLS2
    mov  rdx, N2
    lea  rcx, [head2]
    call init_class

    ; allocate one from each class and print
    mov  rdi, 24
    call slab_alloc
    mov  rbx, rax
    lea  rdi, [fmt]
    mov  esi, CLS0
    mov  rdx, rbx
    xor  eax, eax
    call printf

    mov  rdi, 50
    call slab_alloc
    mov  r12, rax
    lea  rdi, [fmt]
    mov  esi, CLS1
    mov  rdx, r12
    xor  eax, eax
    call printf

    mov  rdi, 100
    call slab_alloc
    mov  r13, rax
    lea  rdi, [fmt]
    mov  esi, CLS2
    mov  rdx, r13
    xor  eax, eax
    call printf

    ; free them back
    mov  rdi, rbx
    mov  rsi, 24
    call slab_free
    mov  rdi, r12
    mov  rsi, 50
    call slab_free
    mov  rdi, r13
    mov  rsi, 100
    call slab_free

    xor  eax, eax
    add  rsp, 8
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp
    ret
