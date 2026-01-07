; Chapter 2 - Lesson 10 - Exercise 2 Solution
; Task: Implement memmove_byte(dst, src, n) handling overlap correctly.
; Constraints: use MOV/LEA for addressing; loop control instructions allowed.
; Self-test: performs an overlapping move within a buffer and verifies expected bytes.
;
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex10.asm -o ex10.o && ld ex10.o -o ex10 && ./ex10 ; echo $?

global _start

section .data
    buf db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

section .text
; rdi=dst, rsi=src, rcx=n (bytes)
memmove_byte:
    ; If dst < src OR dst >= src+n => forward copy is safe.
    ; Otherwise, copy backward.
    lea r8, [rsi + rcx]   ; r8 = src_end
    cmp rdi, rsi
    jb .forward
    cmp rdi, r8
    jae .forward

.backward:
    ; dst_end = dst + n, src_end = src + n
    lea rdi, [rdi + rcx]
    lea rsi, [rsi + rcx]
.bloop:
    test rcx, rcx
    je .done
    lea rdi, [rdi - 1]
    lea rsi, [rsi - 1]
    mov al, [rsi]
    mov [rdi], al
    dec rcx
    jmp .bloop

.forward:
.floop:
    test rcx, rcx
    je .done
    mov al, [rsi]
    mov [rdi], al
    lea rsi, [rsi + 1]
    lea rdi, [rdi + 1]
    dec rcx
    jmp .floop

.done:
    ret

_start:
    ; Overlap test: move bytes buf[0..7] to buf[4..11] (dst inside source range)
    lea rsi, [rel buf]
    lea rdi, [rel buf + 4]
    mov ecx, 8
    call memmove_byte

    ; Expected buffer after memmove:
    ; original: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
    ; move 0..7 to 4..11 => positions 4..11 become 1..8
    ; result should be: 1 2 3 4 1 2 3 4 5 6 7 8 13 14 15 16

    xor edi, edi

    ; Check a few sentinel positions
    cmp byte [rel buf + 4], 1
    je .c1
    or edi, 1
.c1:
    cmp byte [rel buf + 11], 8
    je .c2
    or edi, 2
.c2:
    cmp byte [rel buf + 12], 13
    je .c3
    or edi, 4
.c3:
    mov eax, 60
    syscall
