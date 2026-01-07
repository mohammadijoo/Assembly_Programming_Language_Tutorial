.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 6:
# Relative control flow uses signed displacements encoded in the instruction stream.
# "short" forces an 8-bit displacement (range -128..+127 bytes from next RIP).

_start:
    mov eax, 5
    cmp eax, 10
    jl short .Lsmall                   # conditional jump, 8-bit displacement

    # If we reach here, eax >= 10
    mov edi, 1                         # exit code 1
    jmp short .Ldone

.Lsmall:
    mov edi, 0                         # exit code 0

.Ldone:
    mov eax, 60
    syscall
