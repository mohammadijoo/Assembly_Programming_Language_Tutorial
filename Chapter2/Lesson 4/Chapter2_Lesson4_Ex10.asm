.intel_syntax noprefix
.section .rodata

# Chapter 2, Lesson 4, Exercise Solution 2 (Ex10):
# A byte-accurate self-check: compare bytes emitted by the assembler
# against an "expected opcode" table for a small sequence.

expected:
    # mov rax, rbx       -> 48 89 D8
    .byte 0x48, 0x89, 0xD8
    # add rax, rcx       -> 48 01 C8
    .byte 0x48, 0x01, 0xC8
    # syscall            -> 0F 05
    .byte 0x0F, 0x05

.equ EXPECTED_LEN, (. - expected)

.section .text
.globl _start

test_seq:
    mov rax, rbx
    add rax, rcx
    syscall
test_seq_end:

_start:
    lea rsi, [rip + test_seq]          # actual bytes
    lea rdi, [rip + expected]          # expected bytes
    mov ecx, EXPECTED_LEN

    repe cmpsb                         # compares [rsi] vs [rdi], increments both
    jne .Lfail

    xor edi, edi
    mov eax, 60
    syscall

.Lfail:
    mov edi, 1
    mov eax, 60
    syscall
