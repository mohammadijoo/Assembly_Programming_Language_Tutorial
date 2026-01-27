BITS 64
default rel

global _start
global arena_init
global arena_alloc
global arena_reset

section .bss
align 16
arena_buf  resb 4096      ; backing storage (global)
arena_base dq 0
arena_cap  dq 0
arena_off  dq 0

section .data
msg db "Exercise Solution: simple arena allocator (global state) + alignment", 10
msg_len equ $-msg

section .text
_start:
    lea rdi, [arena_buf]
    mov rsi, 4096
    call arena_init

    ; Allocate 24 bytes (will be aligned to 16)
    mov rdi, 24
    call arena_alloc
    test rax, rax
    jz .fail

    ; Allocate 64 bytes
    mov rdi, 64
    call arena_alloc
    test rax, rax
    jz .fail

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 60
    mov edi, 1
    syscall

; arena_init(base=rdi, cap=rsi)
arena_init:
    mov [rel arena_base], rdi
    mov [rel arena_cap],  rsi
    mov qword [rel arena_off], 0
    ret

; arena_reset()
arena_reset:
    mov qword [rel arena_off], 0
    ret

; arena_alloc(n=rdi) -> rax=ptr or 0
; Align allocations to 16 bytes.
arena_alloc:
    mov rax, [rel arena_off]
    mov rcx, rax

    ; align up: (off + 15) & ~15
    add rcx, 15
    and rcx, -16

    ; new_off = aligned_off + n
    mov rdx, rcx
    add rdx, rdi

    ; if new_off > cap: fail
    mov r8, [rel arena_cap]
    cmp rdx, r8
    ja .oom

    ; ptr = base + aligned_off
    mov r9, [rel arena_base]
    lea rax, [r9+rcx]

    mov [rel arena_off], rdx
    ret

.oom:
    xor eax, eax
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
