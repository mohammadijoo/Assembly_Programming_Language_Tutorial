.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 7:
# Opcode maps and mandatory prefixes (SIMD).
#   pxor xmm0,xmm0 typically encodes with 66 0F ...
#   vpxor ymm0,ymm0,ymm0 uses VEX encoding (C4/C5 prefix families).

_start:
    pxor xmm0, xmm0
    vpxor ymm0, ymm0, ymm0

    mov eax, 60
    xor edi, edi
    syscall
