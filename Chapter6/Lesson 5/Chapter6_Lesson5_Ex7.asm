bits 64
default rel
global _start

section .data
; Node layout (24 bytes):
;   +0  dq value
;   +8  dq left_ptr
;  +16  dq right_ptr
node5: dq 9, 0, 0
node4: dq 2, 0, 0
node3: dq 7, 0, node5
node2: dq 5, node4, 0
node1: dq 10, node2, node3

section .bss
stack_nodes: resq 64          ; explicit stack for iterative traversal

section .text
_start:
    ; Sum of all node values should be 33.
    lea rdi, [rel node1]
    call sum_tree_rec
    mov rbx, rax

    lea rdi, [rel node1]
    call sum_tree_iter

    cmp rax, rbx
    jne .bad
    cmp rax, 33
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; uint64_t sum_tree_rec(Node* n)
; Recursive DFS: sum = value + sum(left) + sum(right)
sum_tree_rec:
    test rdi, rdi
    jz .zero

    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp-8], rdi          ; save node pointer
    mov rax, [rdi + 0]        ; value
    mov [rbp-16], rax

    mov rdi, [rdi + 8]        ; left
    call sum_tree_rec
    mov [rbp-24], rax         ; sum(left)

    mov rdi, [rbp-8]
    mov rdi, [rdi + 16]       ; right
    call sum_tree_rec         ; sum(right) in RAX

    add rax, [rbp-24]
    add rax, [rbp-16]

    leave
    ret

.zero:
    xor eax, eax
    ret

; uint64_t sum_tree_iter(Node* root)
; Same semantics, but no recursion: uses an explicit stack of pointers.
sum_tree_iter:
    push rbx

    xor eax, eax              ; running sum
    test rdi, rdi
    jz .done

    lea r8, [rel stack_nodes]
    xor ebx, ebx              ; top = 0

    mov [r8 + rbx*8], rdi     ; push root
    inc ebx

.loop:
    test ebx, ebx
    jz .done

    dec ebx
    mov r9, [r8 + rbx*8]      ; pop
    test r9, r9
    jz .loop

    add rax, [r9 + 0]         ; sum += value

    mov r10, [r9 + 8]         ; left
    mov r11, [r9 + 16]        ; right

    ; push left (if any)
    test r10, r10
    jz .skipL
    mov [r8 + rbx*8], r10
    inc ebx
.skipL:

    ; push right (if any)
    test r11, r11
    jz .loop
    mov [r8 + rbx*8], r11
    inc ebx
    jmp .loop

.done:
    pop rbx
    ret
