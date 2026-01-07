; Chapter 2 - Lesson 10 - Example 8
; Intel vs AT&T syntax (GAS) for MOV/LEA/XCHG.
; This file is meant to be assembled with GNU as (GAS), not NASM:
;   as --64 Chapter2_Lesson10_Ex8.asm -o ex8.o && ld ex8.o -o ex8 && ./ex8 ; echo $?
;
; We keep the extension .asm to match course naming, but the syntax is GAS.
; It demonstrates:
;   - .intel_syntax noprefix and .att_syntax
;   - same instructions with different operand order and notation

.intel_syntax noprefix
.global _start

.section .data
value: .quad 0x1122334455667788
ptr:   .quad value

.section .text
_start:
    ; Intel syntax:
    lea rbx, [rip + value]      # RBX = &value
    mov rax, [rbx]              # RAX = value
    lea rcx, [rip + ptr]        # RCX = &ptr
    mov rdx, [rcx]              # RDX = ptr (address of value)
    xchg rax, rdx               # swap registers

    ; Switch to AT&T syntax (operand order becomes src,dst; registers get %; immediates get $)
    .att_syntax
    leaq value(%rip), %r8       # R8 = &value
    movq (%r8), %r9             # R9 = value
    xchgq %r8, %r9              # swap registers

    ; Exit with status 0 if RAX now holds ptr (i.e., address of value), else 1
    ; In Intel phase: after xchg rax, rdx => RAX = ptr
    .intel_syntax noprefix
    lea r10, [rip + value]
    cmp rax, r10
    jne fail

    xor edi, edi
    mov eax, 60
    syscall

fail:
    mov edi, 1
    mov eax, 60
    syscall
