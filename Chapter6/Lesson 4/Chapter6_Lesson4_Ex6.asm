BITS 64
default rel

global _start

section .bss
align 16
scratch resb 4096        ; uninitialized global buffer (BSS)

section .data
msg db "zero_scratch(): cleared .bss buffer with REP STOSQ", 10
msg_len equ $-msg

section .text
_start:
    lea rdi, [scratch]
    mov esi, 4096
    call zero_scratch

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; zero_scratch(ptr=rdi, nbytes=esi)
; Demonstrates a local variable holding the loop count.
zero_scratch:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Compute number of qwords (nbytes / 8) and store as local.
    mov eax, esi
    shr eax, 3
    mov [rbp-4], eax

    xor eax, eax        ; value to store
    mov ecx, [rbp-4]    ; count
    ; RDI already points to destination. REP STOSQ uses RDI, RCX, RAX.
    rep stosq

    leave
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
