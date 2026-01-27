; Chapter5_Lesson5_Ex5.asm
; Topic: BREAK/CONTINUE with the LOOP instruction (RCX is implicit)
; Key point: CONTINUE must still execute the LOOP decrement step.
; Example: Iterate k = 1..20. Sum odd k. BREAK if sum exceeds 100.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

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

section .data
    msg_res     db "Sum of odd k (k=1..20) with early break if sum>100: "
    msg_res_len equ $ - msg_res

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; sum = 0
    mov     rbx, 1                   ; k = 1
    mov     rcx, 20                  ; loop count

.loop_body:
    ; if k even => CONTINUE (skip add), but do not skip decrement of RCX
    test    bl, 1
    jz      .continue_to_step

    add     r12, rbx                 ; sum += k
    cmp     r12, 100
    ja      .break_all               ; BREAK out of loop

.continue_to_step:
    inc     rbx                      ; k++
.loop_dec:
    loop    .loop_body               ; RCX-- ; if RCX != 0 jump to loop_body

.after_loop:
    SYS_WRITE msg_res, msg_res_len
    mov     rdi, r12
    call    print_u64_ln
    SYS_EXIT 0

.break_all:
    jmp     .after_loop              ; BREAK: jump to common exit path

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
.loop2:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    rax, rax
    jnz     .loop2
    inc     rsi
    lea     rdx, [outbuf + 32]
    sub     rdx, rsi

.emit:
    SYS_WRITE rsi, rdx
    ret
