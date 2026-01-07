.intel_syntax noprefix
.section .rodata

# Chapter 2, Lesson 4, Exercise Solution 1 (Ex9):
# Minimal instruction-length decoder for a restricted subset of x86-64 encodings.
#
# Supported patterns in the test stream:
#   - optional REX (0x40..0x4F) and legacy prefixes 66/F2/F3 (ignored for length)
#   - one-byte opcodes: 31, 83, 89, 8D, C3, 90
#   - ModRM decoding, SIB handling, disp8/disp32 handling for memory modes
#   - imm8 handling for opcode 83
#
# The program decodes a byte stream, writes per-instruction lengths to an array,
# and exits with status 0 if the total decoded length equals STREAM_LEN.

code_stream:
    # xor eax,eax
    .byte 0x31, 0xC0
    # add eax, 1
    .byte 0x83, 0xC0, 0x01
    # mov rax, rbx
    .byte 0x48, 0x89, 0xD8
    # lea rcx, [rdx + rax*2 + 16]
    .byte 0x48, 0x8D, 0x4C, 0x42, 0x10
    # ret
    .byte 0xC3

.equ STREAM_LEN, (. - code_stream)

.section .bss
.lcomm lengths, 32     # enough for this stream

.section .text
.globl _start

_start:
    lea rsi, [rip + code_stream]       # input pointer
    lea rdi, [rip + lengths]           # output pointer
    xor rbx, rbx                       # total length decoded
    xor r12d, r12d                     # instruction count

.Ldecode_next:
    cmp rbx, STREAM_LEN
    je .Ldone

    mov rdx, rsi                       # rdx = start of current instruction
    call decode_len                    # eax = length
    mov BYTE PTR [rdi], al             # store length
    inc rdi
    add rsi, rax
    add rbx, rax
    inc r12d
    jmp .Ldecode_next

.Ldone:
    cmp rbx, STREAM_LEN
    jne .Lfail

    xor edi, edi                       # status 0
    mov eax, 60
    syscall

.Lfail:
    mov edi, 1                         # status 1
    mov eax, 60
    syscall

# ------------------------------------------------------------
# decode_len(rsi = instruction pointer) -> eax = length
# Clobbers: rcx, r8, r9, r10, r11
# Preserves: rbx, rbp, r12-r15 (SysV AMD64 callee-saved convention)
# ------------------------------------------------------------
decode_len:
    push rbp
    mov rbp, rsp

    mov rcx, rsi                       # cursor
    xor eax, eax                       # length accumulator (will become rcx - rsi)

    # ---- scan prefixes (subset) ----
.Lprefix:
    mov r8b, BYTE PTR [rcx]

    # REX prefix range 0x40..0x4F
    cmp r8b, 0x40
    jb .Llegacy_prefix
    cmp r8b, 0x4F
    jbe .Lconsume_prefix

.Llegacy_prefix:
    # common legacy prefixes we treat as length-only:
    # 66 (operand-size), F2/F3 (rep/repne)
    cmp r8b, 0x66
    je .Lconsume_prefix
    cmp r8b, 0xF2
    je .Lconsume_prefix
    cmp r8b, 0xF3
    je .Lconsume_prefix
    jmp .Lopcode

.Lconsume_prefix:
    inc rcx
    jmp .Lprefix

    # ---- opcode ----
.Lopcode:
    mov r9b, BYTE PTR [rcx]
    inc rcx

    # If you extend this decoder, handle 0x0F escape here.
    cmp r9b, 0xC3
    je .Lfinish_no_modrm
    cmp r9b, 0x90
    je .Lfinish_no_modrm

    # opcodes requiring ModRM in our subset:
    # 31 /r, 89 /r, 8D /r, 83 /digit imm8
    cmp r9b, 0x31
    je .Lneed_modrm
    cmp r9b, 0x89
    je .Lneed_modrm
    cmp r9b, 0x8D
    je .Lneed_modrm
    cmp r9b, 0x83
    je .Lneed_modrm

    # Unknown opcode in this restricted decoder -> fail with length 0
    xor eax, eax
    pop rbp
    ret

.Lneed_modrm:
    mov r10b, BYTE PTR [rcx]           # ModRM
    inc rcx

    # Extract fields:
    # mod = bits 7..6, rm = bits 2..0
    mov r11b, r10b
    shr r11b, 6                        # mod in low bits

    mov r8b, r10b
    and r8b, 0x07                      # rm

    # If mod != 3 and rm == 4, there is a SIB byte.
    cmp r11b, 3
    je .Lmaybe_imm                     # register-direct: no SIB/disp
    cmp r8b, 4
    jne .Ldisp_check

    # consume SIB
    mov r9b, BYTE PTR [rcx]            # SIB
    inc rcx

    # base = bits 2..0 of SIB
    mov r8b, r9b
    and r8b, 0x07
    # if base == 5 and mod == 0, disp32 follows
    cmp r11b, 0
    jne .Ldisp_check
    cmp r8b, 5
    jne .Ldisp_check
    add rcx, 4
    jmp .Lmaybe_imm

.Ldisp_check:
    # Special case: mod==0 and rm==5 => disp32 (RIP-relative in 64-bit)
    cmp r11b, 0
    jne .Ldisp_by_mod
    cmp r8b, 5
    jne .Lmaybe_imm
    add rcx, 4
    jmp .Lmaybe_imm

.Ldisp_by_mod:
    cmp r11b, 1
    jne .Ldisp_mod2
    add rcx, 1                          # disp8
    jmp .Lmaybe_imm

.Ldisp_mod2:
    cmp r11b, 2
    jne .Lmaybe_imm
    add rcx, 4                          # disp32

.Lmaybe_imm:
    # opcode 83 has imm8
    cmp r9b, 0x83
    jne .Lfinish
    add rcx, 1

.Lfinish:
    # eax = rcx - rsi
    mov rax, rcx
    sub rax, rsi
    pop rbp
    ret

.Lfinish_no_modrm:
    mov rax, rcx
    sub rax, rsi
    pop rbp
    ret
