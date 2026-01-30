; Chapter7_Lesson10_Ex15.asm
; Programming Exercise Solution 3 (Very Hard):
; Topic: Arena allocator with alignment + reset that poisons used region.
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex15.asm -o ex15.o
;   ld -o ex15 ex15.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define ARENA_CAP 256

section .bss
arena      resb ARENA_CAP
top_off    resq 1              ; current top offset [0..ARENA_CAP]
used_bytes resq 1              ; for reset poisoning

section .data
msg_ok     db "Arena alloc/reset passed invariants.", 10
msg_ok_len equ $-msg_ok
msg_bad    db "Arena allocator FAILED.", 10
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

; align_up(x=rdi, a=rsi) -> rax
align_up:
    ; assumes a is power of two
    mov rax, rdi
    dec rsi
    add rax, rsi
    not rsi
    and rax, rsi
    ret

; arena_alloc(size=rdi, align=rsi) -> rax=ptr or 0
arena_alloc:
    mov rbx, [top_off]
    mov rdx, rbx
    ; aligned_top = align_up(top_off, align)
    mov rdi, rdx
    call align_up
    mov r8, rax               ; aligned_top

    ; new_top = aligned_top + size (overflow-safe)
    mov r9, r8
    add r9, rdi               ; BUG: rdi clobbered by align_up use; fix below

    ; We'll re-load size from stack by saving upfront:
    ; (This function is short; easiest: require caller passes size in rdi, align in rsi,
    ; so save size in r10 before call align_up.)
    xor eax, eax
    ret

; fixed version
arena_alloc_fixed:
    mov r10, rdi              ; size
    mov r11, rsi              ; align
    mov rbx, [top_off]
    mov rdi, rbx
    mov rsi, r11
    call align_up
    mov r8, rax               ; aligned_top

    mov r9, r8
    add r9, r10
    jc .fail
    cmp r9, ARENA_CAP
    ja .fail

    ; ptr = arena + aligned_top
    lea rax, [arena + r8]
    mov [top_off], r9
    ; track max used for poisoning on reset
    mov rcx, [used_bytes]
    cmp r9, rcx
    cmova rcx, r9
    mov [used_bytes], rcx
    ret
.fail:
    xor eax, eax
    ret

; arena_reset() -> void ; poison [0..used_bytes) with 0xCC and reset top_off
arena_reset:
    mov rcx, [used_bytes]
    test rcx, rcx
    jz .done
    lea rdi, [arena]
    mov al, 0xCC
    rep stosb
.done:
    mov qword [top_off], 0
    mov qword [used_bytes], 0
    ret

_start:
    mov qword [top_off], 0
    mov qword [used_bytes], 0

    ; Allocate 24 bytes aligned 16
    mov rdi, 24
    mov rsi, 16
    call arena_alloc_fixed
    test rax, rax
    jz .fail
    test rax, 15              ; alignment check
    jnz .fail
    mov r12, rax

    ; Allocate 64 bytes aligned 32
    mov rdi, 64
    mov rsi, 32
    call arena_alloc_fixed
    test rax, rax
    jz .fail
    test rax, 31
    jnz .fail
    mov r13, rax

    ; Ensure allocations don't overlap: r13 >= r12 + 24 (conservative)
    mov rax, r12
    add rax, 24
    cmp r13, rax
    jb .fail

    ; Reset and ensure top is 0
    call arena_reset
    cmp qword [top_off], 0
    jne .fail

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout
    xor edi, edi
    jmp exit_

.fail:
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout
    mov edi, 1
    jmp exit_
