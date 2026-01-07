.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 8:
# Mnemonics are assembler tokens. You can create your own mnemonic-like "verbs"
# via macros, and you can emit bytes directly.
#
# This program keeps the raw bytes in the code region but does not execute them;
# it exits normally via the Linux exit syscall.

.macro CLEAR64 reg
    xor \reg, \reg
.endm

.macro NOP3
    # 3-byte NOP (official multi-byte NOP pattern): 0F 1F 00
    .byte 0x0F, 0x1F, 0x00
.endm

_start:
    CLEAR64 rax                        # expands to XOR RAX,RAX
    CLEAR64 rbx

    # Emit a 3-byte NOP as raw bytes:
    NOP3

    jmp .Lexit

raw_bytes:
    # Example of emitting "ret" as raw opcode C3.
    .byte 0xC3

.Lexit:
    mov eax, 60
    xor edi, edi
    syscall
