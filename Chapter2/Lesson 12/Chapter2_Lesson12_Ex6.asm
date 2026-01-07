; Certain base registers force extra encoding bytes.
; [rsp] uses an SIB byte even with no index.
; [rbp] with disp0 is not representable; assembler uses disp8=0.

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    ; set up a simple stack frame-like pointer (without relying on conventions)
    mov     rbp, rsp

    mov     rax, [rsp]      ; requires SIB byte
    mov     rax, [rbp]      ; actually encodes as [rbp+0] with a displacement

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
