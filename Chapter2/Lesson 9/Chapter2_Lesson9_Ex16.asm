; Chapter2_Lesson9_Ex16.asm
; Programming Exercise Solution 5: ring buffer enqueue with power-of-two masking.
; Data model (byte ring):
;   struct ring { buf[SIZE], head, tail }
; where SIZE is a power of two, mask = SIZE-1.
;
; enqueue_byte(rdi=&ring, sil=value) -> al=1 if enqueued, al=0 if full
; Uses LEA for head+1 without affecting FLAGS (then AND for wrap).
;
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex16.asm -o ex16.o
;   ld -o ex16 ex16.o
;
; Expected run result (exit status): 1

default rel
global _start

%define SIZE 8
%define MASK (SIZE - 1)

section .data
; layout: buf[8], head(qword), tail(qword)
ring_buf db 0,0,0,0,0,0,0,0
head     dq 0
tail     dq 0

section .text
; rdi = base pointer to ring (we use global symbols here for simplicity)
; sil = value
enqueue_byte:
    ; load head and tail
    mov rax, [head]
    mov rcx, [tail]

    ; next = (head + 1) & MASK
    lea rdx, [rax + 1]
    and edx, MASK

    ; if next == tail => full
    cmp rdx, rcx
    je .full

    ; store byte at buf[head]
    lea r8, [ring_buf]
    mov [r8 + rax], sil

    ; head = next
    mov [head], rdx

    mov al, 1
    ret

.full:
    xor eax, eax
    ret

_start:
    ; enqueue one byte 'A'
    lea rdi, [ring_buf]
    mov sil, 'A'
    call enqueue_byte

    ; return AL (1 if success)
    movzx edi, al
    mov eax, 60
    syscall
