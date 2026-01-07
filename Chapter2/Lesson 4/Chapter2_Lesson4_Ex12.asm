.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Exercise Solution 4 (Ex12):
# "Build your own mnemonics": macro layer that enforces canonical encodings and
# emits multi-byte NOPs and forced-short branches.

.macro ZERO64 reg
    # Canonical zeroing on x86: XOR reg, reg
    xor \reg, \reg
.endm

.macro MOVZX32 reg, imm32
    # Convention: move a 32-bit immediate into a 64-bit register via the 32-bit
    # subregister (zero-extension happens architecturally).
    mov \reg, \imm32
.endm

.macro NOP5
    # 5-byte NOP pattern: 0F 1F 44 00 00
    .byte 0x0F, 0x1F, 0x44, 0x00, 0x00
.endm

.macro JNZB label
    # Force 8-bit displacement conditional branch (short form).
    jnz short \label
.endm

_start:
    ZERO64 rax
    MOVZX32 eax, 123                   # mov eax, imm32 (zero-extends into rax)
    NOP5

    cmp eax, 123
    JNZB .Lbad

    xor edi, edi
    mov eax, 60
    syscall

.Lbad:
    mov edi, 1
    mov eax, 60
    syscall
