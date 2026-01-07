; Chapter3_Lesson1_Ex13.asm
; Programming Exercise 4 (solution):
; Detect a cycle in a singly-linked list stored in memory and compute a checksum.
; If a cycle is detected, print 0xFFFFFFFFFFFFFFFF (all 1s) as an error sentinel.
; Otherwise, checksum = sum(node.value) over the list.
;
; Uses Floyd's "tortoise and hare" cycle detection:
;   slow = head, fast = head
;   while fast && fast->next:
;       slow = slow->next
;       fast = fast->next->next
;       if slow == fast: cycle
;
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex13.asm -o ex13.o
;   ld ex13.o -o ex13
; Run:
;   ./ex13

%include "Chapter3_Lesson1_Ex1.asm"
default rel

struc NODE
    .value resq 1
    .next  resq 1
endstruc

section .rodata
intro db "Exercise 4 solution: linked list checksum + cycle detection", 10, 0
m_out db "Result = 0x", 0

section .data
align 8
; Toggle between acyclic and cyclic by choosing head.
n4: istruc NODE
    at NODE.value, dq 40
    at NODE.next,  dq 0
    iend

n3: istruc NODE
    at NODE.value, dq 30
    at NODE.next,  dq n4
    iend

n2: istruc NODE
    at NODE.value, dq 20
    at NODE.next,  dq n3
    iend

n1: istruc NODE
    at NODE.value, dq 10
    at NODE.next,  dq n2
    iend

; Uncomment to introduce a cycle: n4.next = n2
; (For demonstration we implement it via a second list head.)
n4_cycle: istruc NODE
    at NODE.value, dq 40
    at NODE.next,  dq n2_cycle
    iend

n3_cycle: istruc NODE
    at NODE.value, dq 30
    at NODE.next,  dq n4_cycle
    iend

n2_cycle: istruc NODE
    at NODE.value, dq 20
    at NODE.next,  dq n3_cycle
    iend

n1_cycle: istruc NODE
    at NODE.value, dq 10
    at NODE.next,  dq n2_cycle
    iend

section .text
global _start

; has_cycle:
;   RDI = head pointer (0 allowed)
;   Returns:
;     RAX = 1 if cycle, 0 if no cycle
;   Clobbers: RAX,RBX,RCX,RDX,RSI,RDI,R8-R11
has_cycle:
    mov rbx, rdi          ; slow
    mov rcx, rdi          ; fast
.loop:
    test rcx, rcx
    jz .no
    mov rdx, [rcx + NODE.next]   ; fast->next
    test rdx, rdx
    jz .no

    ; slow = slow->next
    mov rbx, [rbx + NODE.next]
    ; fast = fast->next->next
    mov rcx, [rdx + NODE.next]

    cmp rbx, rcx
    je .yes
    jmp .loop

.yes:
    mov rax, 1
    ret
.no:
    xor rax, rax
    ret

; checksum_list:
;   RDI = head pointer
;   Returns RAX = sum(value) if acyclic, or -1 if cyclic
checksum_list:
    push rdi
    call has_cycle
    pop rdi
    test rax, rax
    jz .sum

    mov rax, -1
    ret

.sum:
    xor rax, rax
.loop2:
    test rdi, rdi
    jz .done
    add rax, [rdi + NODE.value]
    mov rdi, [rdi + NODE.next]
    jmp .loop2
.done:
    ret

_start:
    lea rdi, [intro]
    call write_z

    ; Choose head:
    ; lea rdi, [n1]          ; acyclic
    lea rdi, [n1_cycle]      ; cyclic

    call checksum_list

    lea rdi, [m_out]
    call write_str_and_hex64

    sys_exit 0
