; Chapter7_Lesson10_Ex14.asm
; Programming Exercise Solution 2 (Very Hard):
; Topic: Ring buffer with power-of-two capacity, push/pop with full/empty detection.
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex14.asm -o ex14.o
;   ld -o ex14 ex14.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define CAP 16
%define MASK (CAP-1)

section .bss
rb_buf    resb CAP
rb_head   resq 1
rb_tail   resq 1
rb_count  resq 1

section .data
msg_ok     db "Ring buffer invariants OK.", 10
msg_ok_len equ $-msg_ok
msg_bad    db "Ring buffer test FAILED.", 10
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

; rb_push(al=value) -> eax=0 ok / 1 full
rb_push:
    mov rax, [rb_count]
    cmp rax, CAP
    jae .full
    mov rcx, [rb_head]
    mov [rb_buf + rcx], al
    inc rcx
    and rcx, MASK
    mov [rb_head], rcx
    inc rax
    mov [rb_count], rax
    xor eax, eax
    ret
.full:
    mov eax, 1
    ret

; rb_pop() -> eax=0 ok / 1 empty, al=value on success
rb_pop:
    mov rax, [rb_count]
    test rax, rax
    jz .empty
    mov rcx, [rb_tail]
    mov al, [rb_buf + rcx]
    inc rcx
    and rcx, MASK
    mov [rb_tail], rcx
    dec rax
    mov [rb_count], rax
    xor eax, eax
    ret
.empty:
    mov eax, 1
    ret

_start:
    ; init
    mov qword [rb_head], 0
    mov qword [rb_tail], 0
    mov qword [rb_count], 0

    ; Push 0..15 (should succeed)
    xor ecx, ecx
.push_loop:
    mov al, cl
    call rb_push
    test eax, eax
    jne .fail
    inc ecx
    cmp ecx, CAP
    jne .push_loop

    ; One more push must fail (full)
    mov al, 0xFF
    call rb_push
    test eax, eax
    je .fail

    ; Pop 0..15 and verify order
    xor ecx, ecx
.pop_loop:
    call rb_pop
    test eax, eax
    jne .fail
    cmp al, cl
    jne .fail
    inc ecx
    cmp ecx, CAP
    jne .pop_loop

    ; Now empty: pop must fail
    call rb_pop
    test eax, eax
    je .fail

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
