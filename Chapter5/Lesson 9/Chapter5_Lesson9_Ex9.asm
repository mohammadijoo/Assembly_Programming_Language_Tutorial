; Chapter5_Lesson9_Ex9.asm
; VERY HARD EXERCISE SOLUTION: Structured nested loops with break/continue discipline.
;
; find_substr(hay=rdi, needle=rsi) -> eax
;   returns first index of needle in hay, or -1 if not found.
;   Both are NUL-terminated ASCII strings.
;
; This is a naive O(n*m) algorithm, but written with clean control-flow:
;   - outer index i over hay
;   - inner index j over needle
;   - early continue when first char mismatches
;   - early break when mismatch in inner loop
;   - returns are routed through a single return block
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex9.asm -o ex9.o
;   ld ex9.o -o ex9

BITS 64
DEFAULT REL

SECTION .rodata
hay1: db "abc___needle___xyz",0
ned1: db "needle",0
hay2: db "short",0
ned2: db "longer",0
hay3: db "aaaaab",0
ned3: db "aab",0

SECTION .text
global _start

; strlen(s=rdi) -> eax
strlen:
    xor     eax, eax
.L_strlen_test:
    cmp     byte [rdi+rax], 0
    je      .L_strlen_done
    inc     eax
    jmp     .L_strlen_test
.L_strlen_done:
    ret

find_substr:
    push    rbp
    mov     rbp, rsp
    push    rbx

    ; Preserve arguments immediately (structured programming rule: save what you will need)
    mov     r9, rdi             ; hay
    mov     r10, rsi            ; needle

    ; m = strlen(needle); empty needle => 0
    mov     rdi, r10
    call    strlen
    mov     r8d, eax            ; m
    test    r8d, r8d
    jz      .L_ret_zero

    ; n = strlen(hay)
    mov     rdi, r9
    call    strlen
    mov     r11d, eax           ; n

    ; if (m > n) return -1
    cmp     r8d, r11d
    ja      .L_ret_not_found

    xor     ecx, ecx            ; i = 0
.L_outer_test:
    ; Stop when i > n-m (remaining < m)
    mov     eax, r11d
    sub     eax, r8d
    cmp     ecx, eax
    ja      .L_ret_not_found

    ; Fast filter: if hay[i] != needle[0], continue
    mov     al, [r9+rcx]
    cmp     al, [r10]
    jne     .L_outer_step

    xor     edx, edx            ; j = 0
.L_inner_test:
    cmp     edx, r8d
    je      .L_ret_found        ; all matched

    mov     al, [r9+rcx+rdx]
    cmp     al, [r10+rdx]
    jne     .L_outer_step       ; mismatch => break inner and advance outer

    inc     edx
    jmp     .L_inner_test

.L_outer_step:
    inc     ecx
    jmp     .L_outer_test

.L_ret_found:
    mov     eax, ecx
    jmp     .L_return

.L_ret_zero:
    xor     eax, eax
    jmp     .L_return

.L_ret_not_found:
    mov     eax, -1
    jmp     .L_return

.L_return:
    pop     rbx
    pop     rbp
    ret

_start:
    ; Test 1: found at index 6 ("abc___" is 6 chars)
    lea     rdi, [hay1]
    lea     rsi, [ned1]
    call    find_substr
    cmp     eax, 6
    jne     .L_fail

    ; Test 2: not found
    lea     rdi, [hay2]
    lea     rsi, [ned2]
    call    find_substr
    cmp     eax, -1
    jne     .L_fail

    ; Test 3: overlapping match (aaaaab, aab) => index 3
    lea     rdi, [hay3]
    lea     rsi, [ned3]
    call    find_substr
    cmp     eax, 3
    jne     .L_fail

    xor     edi, edi
    mov     eax, 60
    syscall

.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall
