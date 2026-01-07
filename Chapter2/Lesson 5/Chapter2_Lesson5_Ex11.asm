# Chapter 2 - Lesson 5 - Ex11 (GAS file showing both syntaxes in one translation unit)
# Assemble with: as -o ex11.o Chapter2_Lesson5_Ex11.asm
.text

.globl add3_intel
.type add3_intel, @function
.intel_syntax noprefix
add3_intel:
    lea rax, [rdi + rsi]
    add rax, rdx
    ret
.att_syntax prefix
.size add3_intel, .-add3_intel

.globl add3_att
.type add3_att, @function
add3_att:
    leaq (%rdi,%rsi), %rax
    addq %rdx, %rax
    ret
.size add3_att, .-add3_att
