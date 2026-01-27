; Chapter5_Lesson2_Ex3.asm
; Topic demo: FOR loop (index-based) with signed/unsigned comparisons
;
; Count how many int32 values satisfy: 0 <= x < 100
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex3.asm -o Chapter5_Lesson2_Ex3.o
;   ld -o Chapter5_Lesson2_Ex3 Chapter5_Lesson2_Ex3.o
;
; Exit status = count (mod 256)

BITS 64
default rel

section .data
arr: dd -7, 0, 5, 99, 100, 2147483647, -1, 42, 13, 101, 88
len equ ($-arr)/4

section .text
global _start

_start:
    xor edi, edi        ; EDI = count
    xor ecx, ecx        ; ECX = i

.for_test:
    cmp ecx, len
    jae .done

    mov eax, [arr + rcx*4]  ; EAX = arr[i]

    ; lower bound: x >= 0 (signed)
    test eax, eax
    js .next                ; if negative, skip

    ; upper bound: x < 100.
    ; Since x is known non-negative here, unsigned and signed are equivalent.
    cmp eax, 100
    jae .next

    inc edi                 ; count++

.next:
    inc ecx                 ; i++
    jmp .for_test

.done:
    and edi, 255
    mov eax, 60             ; SYS_exit
    syscall
