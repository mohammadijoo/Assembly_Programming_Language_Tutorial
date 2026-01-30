; Chapter 7 - Lesson 4 - Exercise Solution 1
; A growable vector of uint64 using realloc.
; Vector = {ptr, len, cap}. Doubling strategy, overflow checks.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex7.asm -o ex7.o
;   gcc -no-pie ex7.o -o ex7

default rel

global main
extern realloc
extern free
extern printf
extern exit

section .data
fmt_sum db "vector len=%ld  sum=%ld", 10, 0
msg_oom db "vector allocation failed", 10, 0

section .text

; void vec_init(vec* v)
; v in rdi
vec_init:
    mov  qword [rdi+0], 0    ; ptr
    mov  qword [rdi+8], 0    ; len
    mov  qword [rdi+16], 0   ; cap
    ret

; int vec_push(vec* v, uint64 value)
; v in rdi, value in rsi, returns eax=0 ok, eax=1 fail
vec_push:
    push rbp
    mov  rbp, rsp
    sub  rsp, 48

    mov  rax, [rdi+8]        ; len
    mov  rdx, [rdi+16]       ; cap
    cmp  rax, rdx
    jb   .have_space

    ; grow: newcap = (cap ? cap*2 : 8)
    test rdx, rdx
    jnz  .cap_nonzero
    mov  rdx, 8
    jmp  .do_realloc
.cap_nonzero:
    cmp  rdx, 0x7fffffffffffffff
    ja   .fail
    shl  rdx, 1

.do_realloc:
    ; bytes = newcap * 8 with overflow check
    mov  rcx, rdx
    cmp  rcx, 0x1fffffffffffffff
    ja   .fail
    lea  rcx, [rdx*8]

    mov  [rbp-8], rdi        ; save v*
    mov  [rbp-16], rsi       ; save value
    mov  rdi, [rdi+0]        ; old ptr (NULL ok)
    mov  rsi, rcx            ; bytes
    call realloc
    test rax, rax
    jz   .fail

    mov  rdi, [rbp-8]        ; restore v*
    mov  [rdi+0], rax        ; ptr = new
    mov  [rdi+16], rdx       ; cap = newcap
    mov  rsi, [rbp-16]       ; restore value

.have_space:
    mov  r10, [rdi+0]        ; ptr
    mov  rax, [rdi+8]        ; len
    mov  [r10 + rax*8], rsi  ; store
    inc  qword [rdi+8]       ; len++
    xor  eax, eax
    leave
    ret

.fail:
    mov  eax, 1
    leave
    ret

; void vec_free(vec* v)
; v in rdi
vec_free:
    mov  rax, [rdi+0]
    test rax, rax
    jz   .z
    mov  rdi, rax
    call free
.z:
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 96

    ; vec on stack: [rbp-48 .. rbp-25]
    lea  rdi, [rbp-48]
    call vec_init

    xor  ecx, ecx
.push_loop:
    cmp  ecx, 1000
    jge  .sum

    mov  rax, rcx
    imul rax, rcx            ; value = i*i

    lea  rdi, [rbp-48]
    mov  rsi, rax
    call vec_push
    test eax, eax
    jnz  .oom

    inc  ecx
    jmp  .push_loop

.sum:
    ; sum all elements
    xor  r8, r8
    xor  ecx, ecx
    mov  r10, [rbp-48]       ; ptr
    mov  r11, [rbp-40]       ; len
.sum_loop:
    cmp  rcx, r11
    jge  .print
    add  r8, [r10 + rcx*8]
    inc  ecx
    jmp  .sum_loop

.print:
    lea  rdi, [fmt_sum]
    mov  rsi, [rbp-40]       ; len
    mov  rdx, r8
    xor  eax, eax
    call printf

    lea  rdi, [rbp-48]
    call vec_free

    xor  eax, eax
    leave
    ret

.oom:
    lea  rdi, [msg_oom]
    xor  eax, eax
    call printf
    lea  rdi, [rbp-48]
    call vec_free
    mov  edi, 1
    call exit
