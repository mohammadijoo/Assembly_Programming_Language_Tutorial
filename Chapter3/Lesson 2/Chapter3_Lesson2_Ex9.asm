; Chapter 3 - Lesson 2 (Programming Exercise 1 — Solution)
; Compute min/max/sum of a signed 64-bit array, store results in variables,
; and print them as signed decimal numbers.
;
; Note: This includes a small itoa routine even though "printing numbers"
; is treated in later chapters; the focus here is heavy variable usage.

BITS 64
default rel

%include "Chapter3_Lesson2_Ex8.asm"

section .rodata
label_min   db "min = "
label_min_len equ $ - label_min

label_max   db "max = "
label_max_len equ $ - label_max

label_sum   db "sum = "
label_sum_len equ $ - label_sum

nl          db 10
nl_len      equ 1

section .data
; Test data
arr         dq  12, -7, 300, -1024, 5, 88, -1, 4096, -99999, 42
arr_len     equ ($ - arr) / 8

v_min       dq 0
v_max       dq 0
v_sum       dq 0

section .bss
outbuf      resb 32         ; enough for signed 64-bit decimal + newline

section .text
global _start

; ------------------------------------------------------------
; itoa_signed
;   rdi = signed 64-bit value
;   rsi = end pointer (one past last writable byte)
; returns:
;   rax = start pointer of produced ASCII
;   rdx = length in bytes
; clobbers: rbx, rcx, r8, r9, r10
; ------------------------------------------------------------
itoa_signed:
    mov     rax, rdi
    mov     rcx, rsi        ; rcx = end
    xor     r8d, r8d        ; r8b = 1 if negative
    test    rax, rax
    jns     .abs_ready
    neg     rax
    mov     r8b, 1
.abs_ready:
    ; handle zero specially
    cmp     rax, 0
    jne     .digits
    dec     rcx
    mov     byte [rcx], '0'
    jmp     .maybe_sign

.digits:
    mov     rbx, 10
.loop:
    xor     rdx, rdx
    div     rbx             ; unsigned div since rax is non-negative
    dec     rcx
    add     dl, '0'
    mov     byte [rcx], dl
    test    rax, rax
    jne     .loop

.maybe_sign:
    cmp     r8b, 0
    je      .done
    dec     rcx
    mov     byte [rcx], '-'

.done:
    mov     rax, rcx
    mov     rdx, rsi
    sub     rdx, rcx
    ret

_start:
    ; Initialize min/max/sum with arr[0]
    mov     rax, qword [arr]
    mov     qword [v_min], rax
    mov     qword [v_max], rax
    mov     qword [v_sum], rax

    mov     rbx, 1          ; i = 1

.scan:
    cmp     rbx, arr_len
    jae     .done_scan

    mov     rax, qword [arr + rbx*8]

    ; sum
    mov     rcx, qword [v_sum]
    add     rcx, rax
    mov     qword [v_sum], rcx

    ; min
    mov     rcx, qword [v_min]
    cmp     rax, rcx
    jge     .check_max
    mov     qword [v_min], rax

.check_max:
    mov     rcx, qword [v_max]
    cmp     rax, rcx
    jle     .next
    mov     qword [v_max], rax

.next:
    inc     rbx
    jmp     .scan

.done_scan:
    ; print min
    WRITE   label_min, label_min_len
    mov     rdi, qword [v_min]
    lea     rsi, [outbuf + 31]
    call    itoa_signed
    ; rax=start, rdx=len
    mov     eax, SYS_write
    mov     edi, STDOUT
    mov     rsi, rax
    syscall
    WRITE   nl, nl_len

    ; print max
    WRITE   label_max, label_max_len
    mov     rdi, qword [v_max]
    lea     rsi, [outbuf + 31]
    call    itoa_signed
    mov     eax, SYS_write
    mov     edi, STDOUT
    mov     rsi, rax
    syscall
    WRITE   nl, nl_len

    ; print sum
    WRITE   label_sum, label_sum_len
    mov     rdi, qword [v_sum]
    lea     rsi, [outbuf + 31]
    call    itoa_signed
    mov     eax, SYS_write
    mov     edi, STDOUT
    mov     rsi, rax
    syscall
    WRITE   nl, nl_len

    EXIT    0
