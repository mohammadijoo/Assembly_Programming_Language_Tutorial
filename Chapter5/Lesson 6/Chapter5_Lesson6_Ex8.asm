bits 64
default rel

global _start
section .text

; Ex8: x86-64 "near" relative control-flow is rel32.
; That means the target must be within approximately +/-2 GiB of the next RIP.
; If you ever need to jump beyond that (rare in user code, relevant in some kernels,
; JITs, or unusual code models), you must use an indirect jump.
;
; Here we demonstrate an indirect jump via a register.

_start:
    ; Compute absolute address of far_target into RAX and jump indirectly.
    lea rax, [rel far_target]
    jmp rax                      ; opcode FF E0 (jmp rax)

    ; If this were a non-PIE executable, you could also do:
    ;   mov rax, far_target
    ;   jmp rax
    ; But in PIE, that creates an absolute relocation that may be rejected.

    times 64 nop

far_target:
    xor edi, edi
    mov eax, 60
    syscall
