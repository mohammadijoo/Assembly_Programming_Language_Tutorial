.intel_syntax noprefix
.section .rodata
arr: .long 10, 20, 30, 40, 50, 60, 70, 80

.section .text
.globl _start

# Chapter 2, Lesson 4, Example 5:
# ModRM + SIB + displacement in action, plus RIP-relative addressing.
#
# Addressing form:
#   [base + index*scale + disp]
# forces the assembler to emit a SIB byte.

_start:
    lea rbx, [rip + arr]               # RIP-relative: disp32 from next RIP
    mov ecx, 3                         # index = 3

    # eax <- arr[ecx]  (scale 4 because .long)
    mov eax, DWORD PTR [rbx + rcx*4]   # expected: ... SIB present

    # edx <- arr[ecx] + 16 bytes offset (i.e., arr[ecx+4])
    mov edx, DWORD PTR [rbx + rcx*4 + 16]

    # exit((eax+edx) & 0xFF)
    add eax, edx
    mov edi, eax
    mov eax, 60
    syscall
