.intel_syntax noprefix
.section .text
.globl _start

# Chapter 2, Lesson 4, Example 3:
# Mixing mnemonics and raw bytes: injecting a single instruction via .byte.

_start:
    mov rax, 7
    mov rbx, 35
    call manual_add                    # returns with rax = rax + rbx

    # exit(status = low 8 bits of rax)
    mov edi, eax
    mov eax, 60
    syscall

manual_add:
    # add rax, rbx  (REX.W + opcode 01 /r + ModRM)
    .byte 0x48, 0x01, 0xD8
    ret
