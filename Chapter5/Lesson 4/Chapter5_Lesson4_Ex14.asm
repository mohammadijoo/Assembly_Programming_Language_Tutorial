; Chapter 5 - Lesson 4 — Programming Exercise 3 (Solution)
; Very hard: Keyword dispatch using a small hash switch + verification.
;
; Goal: Map a short ASCII keyword to an operation id:
;   "add"->1, "sub"->2, "mul"->3, "xor"->4, else 0
;
; Strategy:
;   1) Compute a tiny hash in [0..15].
;   2) Switch on hash with a jump table.
;   3) In each bucket, verify exact string to avoid hash collisions.
;
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex14.asm -o ex14.o
;   ld -o ex14 ex14.o
;   ./ex14

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
; Input (change this to test)
kw: db "mul", 0
kw_len: equ 3

; Output messages
m0: db "op id = 0", 10
l0: equ $-m0
m1: db "op id = 1 (add)", 10
l1: equ $-m1
m2: db "op id = 2 (sub)", 10
l2: equ $-m2
m3: db "op id = 3 (mul)", 10
l3: equ $-m3
m4: db "op id = 4 (xor)", 10
l4: equ $-m4

section .text
_start:
    ; hash = (s[0]*33 + s[1]*7 + len) & 15
    lea rbx, [kw]
    movzx eax, byte [rbx]        ; s[0]
    imul eax, eax, 33
    movzx ecx, byte [rbx + 1]    ; s[1]
    imul ecx, ecx, 7
    add eax, ecx
    add eax, kw_len
    and eax, 15

    lea rdx, [jt]
    jmp qword [rdx + rax*8]

.bucket0:
.bucket1:
.bucket2:
.bucket3:
.bucket4:
.bucket5:
.bucket6:
.bucket7:
.bucket8:
.bucket9:
.bucket10:
.bucket11:
.bucket12:
.bucket13:
.bucket14:
.bucket15:
    ; default bucket: unknown
    lea rsi, [m0]
    mov edx, l0
    jmp .print_exit

; Choose buckets that map to the 4 keywords by recomputing expected hashes (precomputed manually):
; "add": a d d -> hash 9
; "sub": s u b -> hash 7
; "mul": m u l -> hash 14
; "xor": x o r -> hash 10
.case_add: ; hash 9
    ; verify "add"
    lea rbx, [kw]
    cmp byte [rbx], 'a'
    jne .unknown
    cmp byte [rbx+1], 'd'
    jne .unknown
    cmp byte [rbx+2], 'd'
    jne .unknown
    lea rsi, [m1]
    mov edx, l1
    jmp .print_exit

.case_sub: ; hash 7
    lea rbx, [kw]
    cmp byte [rbx], 's'
    jne .unknown
    cmp byte [rbx+1], 'u'
    jne .unknown
    cmp byte [rbx+2], 'b'
    jne .unknown
    lea rsi, [m2]
    mov edx, l2
    jmp .print_exit

.case_mul: ; hash 14
    lea rbx, [kw]
    cmp byte [rbx], 'm'
    jne .unknown
    cmp byte [rbx+1], 'u'
    jne .unknown
    cmp byte [rbx+2], 'l'
    jne .unknown
    lea rsi, [m3]
    mov edx, l3
    jmp .print_exit

.case_xor: ; hash 10
    lea rbx, [kw]
    cmp byte [rbx], 'x'
    jne .unknown
    cmp byte [rbx+1], 'o'
    jne .unknown
    cmp byte [rbx+2], 'r'
    jne .unknown
    lea rsi, [m4]
    mov edx, l4
    jmp .print_exit

.unknown:
    lea rsi, [m0]
    mov edx, l0

.print_exit:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    xor edi, edi
    mov eax, SYS_exit
    syscall

section .rodata
align 8
jt:
    dq .bucket0
    dq .bucket1
    dq .bucket2
    dq .bucket3
    dq .bucket4
    dq .bucket5
    dq .bucket6
    dq .case_sub   ; 7
    dq .bucket8
    dq .case_add   ; 9
    dq .case_xor   ; 10
    dq .bucket11
    dq .bucket12
    dq .bucket13
    dq .case_mul   ; 14
    dq .bucket15
