\
# Chapter2_Lesson6_Ex14.asm
# Programming Exercise 2 (Solution): GAS macros + stack discipline.
#
# This implementation:
# - preserves RBX when used (callee-saved in SysV)
# - keeps RSP 16-byte aligned at call boundaries:
#   On SysV AMD64, the call instruction pushes 8 bytes, so inside a function
#   you typically want RSP % 16 == 8 unless you will call other functions.
#   Here we don't call out, but we still demonstrate correct alignment.
#
# Build:
#   as --64 -g Chapter2_Lesson6_Ex14.asm -o ex14.o
#   gcc -no-pie -g ex14.o -o ex14

.macro PROLOG locals=0, save_rbx=0
    push %rbp
    mov %rsp, %rbp
    .if \save_rbx
        push %rbx
    .endif
    # Ensure space is a multiple of 16 for neatness (not strictly required here).
    sub $\locals, %rsp
.endm

.macro EPILOG locals=0, save_rbx=0
    add $\locals, %rsp
    .if \save_rbx
        pop %rbx
    .endif
    pop %rbp
    ret
.endm

.section .text
.globl sum_u32
.type sum_u32, @function
# uint64_t sum_u32(const uint32_t *a, uint64_t n)
sum_u32:
    PROLOG 0, 1
    xor %rax, %rax           # sum
    xor %rbx, %rbx           # i = 0

.L_loop:
    cmp %rsi, %rbx
    jae .L_done
    mov (%rdi,%rbx,4), %edx  # load uint32_t
    add %rdx, %rax
    inc %rbx
    jmp .L_loop

.L_done:
    EPILOG 0, 1
.size sum_u32, . - sum_u32
