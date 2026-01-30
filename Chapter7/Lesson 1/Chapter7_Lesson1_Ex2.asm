; Chapter 7 - Lesson 1
; Example 2: CALL/RET creates a call stack; observe RSP/RBP across nested calls
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2

global _start

section .data
msg0: db "Entering f1",10
len0: equ $-msg0
msg1: db "Entering f2",10
len1: equ $-msg1
msg2: db "Entering f3",10
len2: equ $-msg2

msg_rsp: db "  RSP = 0x"
len_rsp: equ $-msg_rsp
msg_rbp: db "  RBP = 0x"
len_rbp: equ $-msg_rbp

hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1

section .text

_start:
    ; Start the call chain. Note: CALL pushes an 8-byte return address.
    call f1

    xor edi, edi
    mov eax, 60
    syscall

; -------------------------
; f1 -> f2 -> f3 (each uses a classic frame pointer)
; -------------------------
f1:
    push rbp
    mov rbp, rsp
    sub rsp, 32          ; reserve locals (and keep alignment sane for internal calls)

    mov rdi, msg0
    mov rsi, len0
    call write_buf
    call dump_sp_bp

    call f2

    leave
    ret

f2:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov rdi, msg1
    mov rsi, len1
    call write_buf
    call dump_sp_bp

    call f3

    leave
    ret

f3:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    mov rdi, msg2
    mov rsi, len2
    call write_buf
    call dump_sp_bp

    ; do some stack-local writes so you can inspect memory in a debugger
    mov qword [rbp-8],  0xaaaaaaaaaaaaaaaa
    mov qword [rbp-16], 0xbbbbbbbbbbbbbbbb
    mov qword [rbp-24], 0xcccccccccccccccc

    leave
    ret

; -------------------------
; dump_sp_bp(): prints current RSP and RBP as hex
; clobbers: rax, rcx, rdx, rsi, rdi, r8
; -------------------------
dump_sp_bp:
    mov rdi, msg_rsp
    mov rsi, len_rsp
    call write_buf
    mov rax, rsp
    call print_hex64

    mov rdi, msg_rbp
    mov rsi, len_rbp
    call write_buf
    mov rax, rbp
    call print_hex64
    ret

; write_buf(rdi=ptr, rsi=len)
write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

; print_hex64(rax=value): 16 hex digits + '\n'
print_hex64:
    lea rdi, [rel hexbuf]
    mov rcx, 16
    lea r8,  [rel hex_digits]
.loop:
    mov rdx, rax
    shr rdx, 60
    mov dl, [r8 + rdx]
    mov [rdi], dl
    inc rdi
    shl rax, 4
    dec rcx
    jnz .loop
    mov byte [rdi], 10
    lea rdi, [rel hexbuf]
    mov rsi, 17
    jmp write_buf
