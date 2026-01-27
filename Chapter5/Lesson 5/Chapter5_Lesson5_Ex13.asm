; Chapter5_Lesson5_Ex13.asm
; Optional (Advanced): A lightweight NASM macro pattern for structured FOR loops
; providing BREAK and CONTINUE for the innermost active loop via a context stack.
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o

BITS 64
default rel

%macro SYS_WRITE 2
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2
    syscall
%endmacro

%macro SYS_EXIT 1
    mov     rax, 60
    mov     rdi, %1
    syscall
%endmacro

; ------------------------------------------------------------
; Context-scoped FOR loop macros
; FOR_BEGIN reg, start, end_inclusive
;   ... body ...
; FOR_END
;
; BREAK and CONTINUE always target the innermost active FOR loop.
; Nested FOR loops work because we push/pop a preprocessor context.
; ------------------------------------------------------------

%macro FOR_BEGIN 3
    %push forctx
    %define __FOR_REG  %1
    %define __BREAK    %$for_end
    %define __CONTINUE %$for_step

    mov     __FOR_REG, %2

%$for_test:
    cmp     __FOR_REG, %3
    jg      %$for_end
%endmacro

%macro FOR_END 0
%$for_step:
    inc     __FOR_REG
    jmp     %$for_test

%$for_end:
    %undef  __FOR_REG
    %undef  __BREAK
    %undef  __CONTINUE
    %pop
%endmacro

%macro BREAK 0
    jmp     __BREAK
%endmacro

%macro CONTINUE 0
    jmp     __CONTINUE
%endmacro

section .data
    msg         db "Pairs processed (skip j==3; break inner at i==4,j==2): "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; count = 0

    ; for (i=1; i<=5; i++)
    FOR_BEGIN rbx, 1, 5

        ; for (j=1; j<=5; j++)
        FOR_BEGIN rcx, 1, 5

            cmp     rcx, 3
            je      .skip_j           ; CONTINUE inner

            cmp     rbx, 4
            jne     .count_pair
            cmp     rcx, 2
            je      .break_inner      ; BREAK inner

.count_pair:
            inc     r12
            jmp     .done_inner_body

.skip_j:
            CONTINUE                 ; continue inner loop (j++)
.done_inner_body:
            ; fall through

.break_inner:
            ; If the condition matched, BREAK exits inner loop; otherwise it is a no-op path.
            cmp     rbx, 4
            jne     .after_break_check
            cmp     rcx, 2
            jne     .after_break_check
            BREAK                    ; break inner loop

.after_break_check:
        FOR_END

    FOR_END

    SYS_WRITE msg, msg_len
    mov     rdi, r12
    call    print_u64_ln
    SYS_EXIT 0

; print_u64_ln: unsigned in RDI + newline
print_u64_ln:
    lea     r8,  [outbuf + 31]
    mov     byte [r8], 10
    lea     rsi, [outbuf + 30]

    mov     rax, rdi
    cmp     rax, 0
    jne     .conv
    mov     byte [rsi], '0'
    mov     rdx, 2
    jmp     .emit

.conv:
    mov     rbx, 10
.loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    rax, rax
    jnz     .loop
    inc     rsi
    lea     rdx, [outbuf + 32]
    sub     rdx, rsi

.emit:
    SYS_WRITE rsi, rdx
    ret
