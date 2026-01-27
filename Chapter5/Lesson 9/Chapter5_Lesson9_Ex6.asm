; Chapter5_Lesson9_Ex6.asm
; HARD EXERCISE SOLUTION: Robust atoi32 with validation + overflow detection.
;
; atoi32_checked(s=rdi) returns:
;   eax = parsed int32 (undefined on error),
;   edx = status (0=OK, 1=INVALID, 2=OVERFLOW)
;
; Rules:
; - Optional leading spaces (ASCII 0x20 only for simplicity)
; - Optional leading '+' or '-'
; - At least one digit required
; - Reject any trailing non-space characters
; - Detect int32 overflow/underflow
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex6.asm -o ex6.o
;   ld ex6.o -o ex6

BITS 64
DEFAULT REL

SECTION .rodata
t1: db "   -2147483648",0
t2: db "2147483647",0
t3: db "2147483648",0          ; overflow
t4: db "12x",0                  ; invalid
t5: db "   +0   ",0

SECTION .text
global _start

; atoi32_checked(s=rdi) -> eax, edx
atoi32_checked:
    push    rbp
    mov     rbp, rsp
    push    rbx

    xor     eax, eax
    xor     edx, edx            ; status = 0
    xor     ebx, ebx            ; sign = 0 (0=+,1=-)

    ; skip leading spaces
.L_skip_space:
    mov     cl, [rdi]
    test    cl, cl
    jz      .L_invalid
    cmp     cl, ' '
    jne     .L_sign
    inc     rdi
    jmp     .L_skip_space

.L_sign:
    mov     cl, [rdi]
    cmp     cl, '-'
    jne     .L_plus
    mov     bl, 1
    inc     rdi
    jmp     .L_first_digit
.L_plus:
    cmp     cl, '+'
    jne     .L_first_digit
    inc     rdi

.L_first_digit:
    mov     cl, [rdi]
    cmp     cl, '0'
    jb      .L_invalid
    cmp     cl, '9'
    ja      .L_invalid

    ; Accumulate magnitude in rax, check bounds each step.
    ; Boundaries:
    ;   INT_MAX =  2147483647
    ;   INT_MIN = -2147483648  (magnitude 2147483648 allowed when sign is negative)
    xor     rax, rax

.L_accum_loop:
    mov     cl, [rdi]
    test    cl, cl
    jz      .L_finish
    cmp     cl, ' '
    je      .L_trailing_space

    cmp     cl, '0'
    jb      .L_invalid
    cmp     cl, '9'
    ja      .L_invalid

    ; digit = cl - '0'
    movzx   ecx, byte [rdi]
    sub     ecx, '0'

    ; rax = rax*10 + digit
    imul    rax, rax, 10
    add     rax, rcx

    ; overflow check on magnitude
    cmp     bl, 0
    jne     .L_check_neg
    cmp     rax, 2147483647
    ja      .L_overflow
    jmp     .L_next
.L_check_neg:
    cmp     rax, 2147483648
    ja      .L_overflow

.L_next:
    inc     rdi
    jmp     .L_accum_loop

.L_trailing_space:
    ; consume spaces; then require end
.L_trail:
    mov     cl, [rdi]
    test    cl, cl
    jz      .L_finish
    cmp     cl, ' '
    jne     .L_invalid
    inc     rdi
    jmp     .L_trail

.L_finish:
    cmp     bl, 0
    je      .L_pos_done
    neg     rax
.L_pos_done:
    mov     eax, eax            ; value already in range
    xor     edx, edx            ; OK
    jmp     .L_done

.L_invalid:
    mov     edx, 1
    jmp     .L_done
.L_overflow:
    mov     edx, 2
    jmp     .L_done

.L_done:
    pop     rbx
    pop     rbp
    ret

; test harness: exits 0 if all checks pass
_start:
    ; t1 -> -2147483648 OK
    lea     rdi, [t1]
    call    atoi32_checked
    cmp     edx, 0
    jne     .L_fail
    cmp     eax, 0x80000000
    jne     .L_fail

    ; t2 -> 2147483647 OK
    lea     rdi, [t2]
    call    atoi32_checked
    cmp     edx, 0
    jne     .L_fail
    cmp     eax, 2147483647
    jne     .L_fail

    ; t3 overflow
    lea     rdi, [t3]
    call    atoi32_checked
    cmp     edx, 2
    jne     .L_fail

    ; t4 invalid
    lea     rdi, [t4]
    call    atoi32_checked
    cmp     edx, 1
    jne     .L_fail

    ; t5 -> 0 OK
    lea     rdi, [t5]
    call    atoi32_checked
    cmp     edx, 0
    jne     .L_fail
    test    eax, eax
    jne     .L_fail

    xor     edi, edi
    mov     eax, 60
    syscall

.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall
