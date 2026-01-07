.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 2:
# Same "idea" at the source level can select different encodings.
# Inspect with:
#   objdump -d -Mintel ex2

_start:
    # PUSH/POP register opcodes are "opcode + register id" (plus REX for r8-r15).
    push rax                           # expected: 50
    push r8                            # expected: 41 50
    pop r8                             # expected: 41 58
    pop rax                            # expected: 58

    # INC has a dedicated opcode in legacy x86, but in x86-64 those bytes collide with REX prefixes.
    # Therefore assemblers encode INC r/m32 as FF /0 (needs ModRM).
    inc eax                            # expected: FF C0
    add eax, 1                         # expected: 83 C0 01

    # NOP has many encodings. Some assemblers may encode xchg eax,eax as 90,
    # but GNU as commonly emits the generic xchg form (87 C0). Both are valid.
    xchg eax, eax                      # expected: 87 C0 (or 90, toolchain-dependent)

    mov eax, 60
    xor edi, edi
    syscall
