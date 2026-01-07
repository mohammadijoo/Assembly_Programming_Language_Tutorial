; Chapter 2 - Lesson 10 - Exercise 3 Solution (Very Hard)
; Task: In-place selection sort of an array of signed 32-bit integers using LEA for addressing
; and XCHG+MOV idiom for swapping elements. (CMP/Jcc for comparisons is allowed.)
; Self-test: sorts 12 values and validates non-decreasing order.
;
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex11.asm -o ex11.o && ld ex11.o -o ex11 && ./ex11 ; echo $?

global _start

section .data
    ; signed dwords
    arr dd  7, -3, 12, 0, 5, -9, 2, 2, 100, -1, 8, -3
    n   equ 12

section .text
; rdi = base pointer, ecx = n
selection_sort_i32:
    xor r8d, r8d              ; i = 0
.outer:
    cmp r8d, ecx
    jae .done

    ; min_idx = i
    mov r9d, r8d
    ; min_val = arr[i]
    lea r10, [rdi + r8*4]
    mov eax, dword [r10]

    ; j = i+1
    lea r11d, [r8d + 1]
.inner:
    cmp r11d, ecx
    jae .swap

    lea r12, [rdi + r11*4]
    mov edx, dword [r12]
    cmp edx, eax
    jge .nextj
    mov eax, edx              ; min_val = arr[j]
    mov r9d, r11d             ; min_idx = j
.nextj:
    inc r11d
    jmp .inner

.swap:
    ; if min_idx != i: swap arr[i], arr[min_idx]
    cmp r9d, r8d
    je .nexti

    lea r10, [rdi + r8*4]
    lea r12, [rdi + r9*4]

    ; swap using MOV + XCHG-with-mem:
    ;   tmp = arr[i]
    ;   tmp <-> arr[min]
    ;   arr[i] = tmp
    mov eax, dword [r10]
    xchg eax, dword [r12]
    mov dword [r10], eax

.nexti:
    inc r8d
    jmp .outer

.done:
    ret

_start:
    lea rdi, [rel arr]
    mov ecx, n
    call selection_sort_i32

    ; Validate sorted: arr[k] <= arr[k+1] for all k
    xor edi, edi
    lea rsi, [rel arr]
    mov ecx, n
    dec ecx
.chk:
    mov eax, dword [rsi]
    mov edx, dword [rsi + 4]
    cmp eax, edx
    jle .ok
    mov edi, 1
    jmp .exit
.ok:
    lea rsi, [rsi + 4]
    dec ecx
    jnz .chk

.exit:
    mov eax, 60
    syscall
