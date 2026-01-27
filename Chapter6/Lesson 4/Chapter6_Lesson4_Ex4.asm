BITS 64
default rel

global _start
global redzone_add

section .data
msg db "redzone_add(): wrote temporaries into the SysV red zone (leaf only)", 10
msg_len equ $-msg

section .text
_start:
    ; redzone_add(40, 2) = 42
    mov rdi, 40
    mov rsi, 2
    call redzone_add

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; redzone_add(a=rdi, b=rsi) -> rax
; SysV AMD64 defines a 128-byte "red zone" below RSP that leaf functions
; may use without adjusting RSP. Do NOT use this if you might call other
; functions or if you target an ABI without a red zone (e.g., Windows x64).
redzone_add:
    mov [rsp-8],  rdi
    mov [rsp-16], rsi

    mov rax, [rsp-8]
    add rax, [rsp-16]
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
