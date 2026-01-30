; Chapter 7 - Lesson 3 - Example 11 (Exercise Solution 1)
; Dynamic array of uint64_t with doubling growth using realloc
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex11.asm -o ex11.o
;   gcc -no-pie ex11.o -o ex11
;
; Data structure:
;   struct vec {
;       uint64_t *data;
;       uint64_t  len;
;       uint64_t  cap;
;   };

default rel
global main
extern malloc
extern realloc
extern free
extern printf

section .data
fmt db "len=%d cap=%d last=%llu", 10, 0

section .bss
vec_data resq 1
vec_len  resq 1
vec_cap  resq 1

section .text
; ensure_capacity(min_cap)
; RDI = min_cap
; returns CF=0 on success, CF=1 on failure
ensure_capacity:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8

    mov  rax, [vec_cap]
    cmp  rax, rdi
    jae  .ok

    ; new_cap = max(1, cap); while new_cap < min_cap: new_cap *= 2
    mov  rbx, rax
    test rbx, rbx
    jnz  .loop
    mov  rbx, 1
.loop:
    cmp  rbx, rdi
    jae  .grow_done
    shl  rbx, 1
    jmp  .loop

.grow_done:
    ; bytes = new_cap * 8
    mov  rdx, rbx
    shl  rdx, 3

    mov  rax, [vec_data]
    test rax, rax
    jz   .first_alloc

    ; realloc(existing, bytes)
    mov  rdi, rax
    mov  rsi, rdx
    call realloc
    test rax, rax
    jz   .fail
    mov  [vec_data], rax
    mov  [vec_cap], rbx
    jmp  .ok

.first_alloc:
    ; malloc(bytes)
    mov  rdi, rdx
    call malloc
    test rax, rax
    jz   .fail
    mov  [vec_data], rax
    mov  [vec_cap], rbx

.ok:
    clc
    pop  r15
    pop  rbx
    pop  rbp
    ret

.fail:
    stc
    pop  r15
    pop  rbx
    pop  rbp
    ret

; push(value)
; RDI=value
; returns CF=0 success, CF=1 failure
push:
    push rbp
    mov  rbp, rsp
    push rbx
    push r15

    mov  r15, rdi              ; save value
    mov  rbx, [vec_len]
    lea  rax, [rbx+1]
    mov  rdi, rax
    call ensure_capacity
    jc   .fail

    mov  rdx, [vec_data]
    mov  [rdx + rbx*8], r15     ; store value
    inc  qword [vec_len]
    clc
    jmp  .done

.fail:
    stc
.done:
    pop  r15
    pop  rbx
    pop  rbp
    ret

main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8

    ; initialize
    mov  qword [vec_data], 0
    mov  qword [vec_len],  0
    mov  qword [vec_cap],  0

    ; push 1..1000
    mov  ecx, 1
.loop_push:
    cmp  ecx, 1000
    jg   .done_push
    mov  rdi, rcx
    call push
    jc   .oom
    inc  ecx
    jmp  .loop_push

.done_push:
    ; print summary
    mov  rax, [vec_len]
    mov  rbx, [vec_cap]
    mov  rdx, [vec_data]
    mov  r8,  [rdx + (1000-1)*8]

    lea  rdi, [fmt]
    mov  esi, eax
    mov  edx, ebx
    mov  rcx, r8
    xor  eax, eax
    call printf

    mov  rdi, [vec_data]
    call free

    xor  eax, eax
    pop  r15
    pop  rbx
    pop  rbp
    ret

.oom:
    mov  rdi, [vec_data]
    test rdi, rdi
    jz   .exit_fail
    call free
.exit_fail:
    mov  eax, 1
    pop  r15
    pop  rbx
    pop  rbp
    ret
