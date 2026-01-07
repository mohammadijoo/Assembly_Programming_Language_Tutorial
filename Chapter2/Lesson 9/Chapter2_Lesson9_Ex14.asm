; Chapter2_Lesson9_Ex14.asm
; Programming Exercise Solution 3: reverse an array of qwords in place.
; Prototype:
;   reverse_qwords(arr=rdi, len=rcx)
;
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex14.asm -o ex14.o
;   ld -o ex14 ex14.o
;
; Expected run result (exit status): 7

default rel
global _start

section .data
arr dq 1,2,3,4,5,6,7

section .text
reverse_qwords:
    ; If len <= 1, nothing to do.
    cmp rcx, 1
    jbe .done

    mov r8, rdi                   ; left
    lea r9, [rdi + rcx*8 - 8]     ; right

.loop:
    cmp r8, r9
    jae .done

    ; swap [left] and [right] using one temp register + XCHG
    mov rax, [r8]
    xchg rax, [r9]
    mov [r8], rax

    add r8, 8
    sub r9, 8
    jmp .loop

.done:
    ret

_start:
    lea rdi, [arr]
    mov ecx, 7
    call reverse_qwords

    ; Exit with arr[0] after reversal, expected 7.
    mov rax, [arr]
    mov eax, 60
    mov edi, eax
    syscall
