\
# Chapter2_Lesson6_Ex13.asm
# Programming Exercise 2 (Starter): GAS macros + stack discipline.
# Goal: implement a macro that creates a 16-byte-aligned stack frame and
# preserves callee-saved registers used inside the function.
#
# Implement:
#   - PROLOG macro: sets up RBP frame, allocates locals, preserves RBX if used
#   - EPILOG macro: restores and returns
#
# Then write:
#   uint64_t sum_u32(const uint32_t *a, uint64_t n)
# in SysV ABI: a in RDI, n in RSI, return in RAX.
#
# Build (Linux):
#   as --64 -g Chapter2_Lesson6_Ex13.asm -o ex13.o
#   gcc -no-pie -g ex13.o -o ex13
#
# NOTE: Starter assembles but function is incomplete.

.macro PROLOG locals=0
    push %rbp
    mov %rsp, %rbp
    # TODO: keep stack aligned to 16 at call sites; allocate locals
    sub $\locals, %rsp
.endm

.macro EPILOG locals=0
    add $\locals, %rsp
    pop %rbp
    ret
.endm

.section .text
.globl sum_u32
.type sum_u32, @function
sum_u32:
    PROLOG 0
    xor %rax, %rax
    # TODO: implement loop over n elements at [rdi], accumulate into rax
    EPILOG 0
.size sum_u32, . - sum_u32
