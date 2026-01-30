; Chapter7_Lesson10_Ex9.asm
; Topic: Handle table + generation counters to reduce UAF risk (indirection pattern)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define N_HANDLES 8

section .bss
handle_ptrs   resq N_HANDLES          ; ptr per slot
handle_gens   resd N_HANDLES          ; generation per slot
handle_pad    resd N_HANDLES          ; padding for alignment
buf_pool      resb 64                 ; pretend allocations come from here

section .data
msg_ok      db "Old handle rejected after free (generation mismatch).", 10
msg_ok_len  equ $-msg_ok
msg_bad     db "BUG: stale handle still resolved!", 10
msg_bad_len equ $-msg_bad

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

; make_handle(index=eax, gen=edx) -> rax = (gen<<32) | index
make_handle:
    shl rdx, 32
    mov eax, eax
    or rax, rdx
    ret

; handle_alloc(ptr=rdi) -> rax=handle (0 on failure)
handle_alloc:
    xor eax, eax
    xor ecx, ecx
.find:
    cmp ecx, N_HANDLES
    jae .fail
    mov rbx, [handle_ptrs + rcx*8]
    test rbx, rbx
    jz .use
    inc ecx
    jmp .find
.use:
    mov [handle_ptrs + rcx*8], rdi
    ; gen := gen + 1 (never 0 after first alloc)
    mov edx, [handle_gens + rcx*4]
    add edx, 1
    mov [handle_gens + rcx*4], edx
    mov eax, ecx
    call make_handle
    ret
.fail:
    xor eax, eax
    ret

; handle_free(handle=rdi) -> void (increments generation, clears ptr)
handle_free:
    mov eax, edi              ; low32 = index
    shr rdi, 32               ; rdi = gen (unused here)
    cmp eax, N_HANDLES
    jae .done
    mov qword [handle_ptrs + rax*8], 0
    ; bump gen to invalidate old handles
    mov edx, [handle_gens + rax*4]
    add edx, 1
    mov [handle_gens + rax*4], edx
.done:
    ret

; handle_get(handle=rdi) -> rax=ptr or 0
handle_get:
    ; handle layout: [gen:32 | index:32]
    mov rax, rdi
    mov ecx, eax              ; index
    shr rax, 32
    mov edx, eax              ; gen

    cmp ecx, N_HANDLES
    jae .fail
    cmp edx, [handle_gens + rcx*4]
    jne .fail
    mov rax, [handle_ptrs + rcx*8]
    ret
.fail:
    xor eax, eax
    ret

_start:
    ; Allocate a handle to some memory in buf_pool
    lea rdi, [buf_pool]
    call handle_alloc
    test rax, rax
    jz .bad

    mov r12, rax              ; keep handle

    ; Free it (stale handle should die)
    mov rdi, r12
    call handle_free

    ; Try to resolve stale handle
    mov rdi, r12
    call handle_get
    test rax, rax
    jnz .bad

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout
    xor edi, edi
    jmp exit_

.bad:
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout
    mov edi, 1
    jmp exit_
