.intel_syntax noprefix
.section .rodata
data_qword: .quad 0xAABBCCDDEEFF0011

.section .text
.globl _start

# Chapter 2, Lesson 4, Example 4:
# MOV "direction": 89 /r vs 8B /r and immediate forms (B8+rd).
# Disassemble to observe:
#   mov [mem], reg  -> opcode 89 /r
#   mov reg, [mem]  -> opcode 8B /r
#   mov reg, imm    -> opcode B8+rd (for register destinations)

_start:
    lea rsi, [rip + data_qword]

    mov rax, 0x1122334455667788        # expected: 48 B8 imm64
    mov [rsi], rax                     # expected: 48 89 06 (r/m64 <- r64)
    mov rbx, [rsi]                     # expected: 48 8B 1E (r64 <- r/m64)

    # When the destination is a register, "mov reg, imm" uses B8+rd.
    mov r10, 0x0102030405060708        # expected: 49 BA 08 07 06 05 04 03 02 01

    mov eax, 60
    xor edi, edi
    syscall
