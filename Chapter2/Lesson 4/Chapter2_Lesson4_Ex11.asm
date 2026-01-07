.intel_syntax noprefix
.section .rodata

# Chapter 2, Lesson 4, Exercise Solution 3 (Ex11):
# Emit the machine-code bytes for:
#   mov r64, imm64
# Encoding:
#   REX.W + (B8 + (reg&7)) + imm64
# Where REX.B is set if reg>=8 (to extend the register id).
#
# We emit into a buffer and validate against an expected pattern for r10.

expected_r10:
    # mov r10, 0x1122334455667788
    .byte 0x49, 0xBA, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11

.equ EMIT_LEN, 10

.section .bss
.lcomm outbuf, 32

.section .text
.globl _start

_start:
    lea rdi, [rip + outbuf]            # output buffer
    mov esi, 10                        # register id: r10
    mov rdx, 0x1122334455667788
    call emit_mov_imm64

    # Compare emitted bytes to expected.
    lea rsi, [rip + outbuf]
    lea rdi, [rip + expected_r10]
    mov ecx, EMIT_LEN
    repe cmpsb
    jne .Lfail

    xor edi, edi
    mov eax, 60
    syscall

.Lfail:
    mov edi, 1
    mov eax, 60
    syscall

# emit_mov_imm64(rdi=dst, esi=reg_id, rdx=imm64) -> eax=len (10)
emit_mov_imm64:
    push rbp
    mov rbp, rsp

    # REX = 0x48 | (reg_id>>3)  (W=1, B=high bit)
    mov eax, esi
    shr eax, 3
    and eax, 1
    or eax, 0x48
    mov BYTE PTR [rdi], al

    # opcode = 0xB8 + (reg_id & 7)
    mov eax, esi
    and eax, 7
    add eax, 0xB8
    mov BYTE PTR [rdi + 1], al

    # imm64 in little-endian
    mov QWORD PTR [rdi + 2], rdx

    mov eax, EMIT_LEN
    pop rbp
    ret
