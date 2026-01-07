.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 1:
# A compact instruction sequence that is easy to inspect with a disassembler.
# Build (Linux x86-64, GNU as + ld):
#   as Chapter2_Lesson4_Ex1.asm -o ex1.o
#   ld ex1.o -o ex1
# Inspect bytes:
#   objdump -d -Mintel ex1

_start:
    xor eax, eax                       # expected: 31 C0
    mov rbx, 0x1122334455667788        # expected: 48 BB 88 77 66 55 44 33 22 11
    add rax, rbx                       # expected: 48 01 D8

    # LEA uses ModRM + SIB + displacement. Here:
    #   rcx <- rdx + rax*2 + 16
    lea rcx, [rdx + rax*2 + 16]        # expected: 48 8D 4C 42 10

    cmp rax, 100                       # expected: 48 83 F8 64
    jne short .Lskip                   # expected: 75 ?? (short Jcc; displacement depends on layout)
    nop                                # expected: 90
.Lskip:
    mov eax, 60                        # exit syscall
    xor edi, edi
    syscall                            # expected: 0F 05
