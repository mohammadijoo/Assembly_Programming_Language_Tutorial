; Chapter 7 - Lesson 1
; Example 6: Simple backtrace via RBP chain (requires frame pointers)
;
; We walk the saved RBP links:
;   current_rbp -> [rbp] = previous_rbp
;                 [rbp+8] = return address
; This is how many debuggers/unwinders can do a "naive" backtrace when
; frame pointers exist (and optimizations didn't omit them).
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

global _start

section .data
hdr: db "Backtrace return addresses:",10
hdr_len: equ $-hdr
hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1

section .text

_start:
    call a

    xor edi, edi
    mov eax, 60
    syscall

a:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call b
    leave
    ret

b:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call c
    leave
    ret

c:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rdi, hdr
    mov rsi, hdr_len
    call write_buf

    ; walk up to 8 frames or until RBP becomes non-canonical/NULL (best-effort)
    mov rbx, rbp
    mov ecx, 8
.walk:
    test rbx, rbx
    jz .done

    ; return address is stored at [rbx+8]
    mov rax, [rbx + 8]
    call print_hex64

    ; previous frame pointer at [rbx]
    mov rbx, [rbx]
    dec ecx
    jnz .walk

.done:
    leave
    ret

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

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
