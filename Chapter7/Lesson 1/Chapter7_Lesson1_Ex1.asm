; Chapter 7 - Lesson 1
; Example 1: PUSH/POP as a strict LIFO + stack-balance sanity checks
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson1_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1

global _start

section .data
ok_msg:     db "OK: LIFO and balanced stack", 10
ok_len:     equ $-ok_msg
fail_msg:   db "FAIL: unexpected POP order or unbalanced stack", 10
fail_len:   equ $-fail_msg
rsp0_msg:   db "RSP at entry: 0x"
rsp0_len:   equ $-rsp0_msg
rsp1_msg:   db "RSP after PUSHes: 0x"
rsp1_len:   equ $-rsp1_msg
rsp2_msg:   db "RSP after POPs:  0x"
rsp2_len:   equ $-rsp2_msg

hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1+1   ; 16 hex chars + '\n' + '\0' (nul not written)

section .text

_start:
    mov r12, rsp                 ; save RSP at entry (r12 is just a temp here)

    ; Print RSP at entry
    mov rdi, rsp0_msg
    mov rsi, rsp0_len
    call write_buf
    mov rax, r12
    call print_hex64

    ; Push four known 64-bit values (stack grows "down": RSP decreases)
    mov rax, 0x1111111122222222
    push rax
    mov rax, 0x3333333344444444
    push rax
    mov rax, 0x5555555566666666
    push rax
    mov rax, 0x7777777788888888
    push rax

    mov r13, rsp                 ; RSP after pushes

    mov rdi, rsp1_msg
    mov rsi, rsp1_len
    call write_buf
    mov rax, r13
    call print_hex64

    ; Pop them back: must come out in reverse order
    pop rbx                       ; expect 0x777...
    pop rcx                       ; expect 0x555...
    pop rdx                       ; expect 0x333...
    pop r8                        ; expect 0x111...

    mov r14, rsp                 ; RSP after pops (should equal entry RSP)

    mov rdi, rsp2_msg
    mov rsi, rsp2_len
    call write_buf
    mov rax, r14
    call print_hex64

    ; Verify LIFO order
    mov rax, 0x7777777788888888
    cmp rbx, rax
    jne .fail
    mov rax, 0x5555555566666666
    cmp rcx, rax
    jne .fail
    mov rax, 0x3333333344444444
    cmp rdx, rax
    jne .fail
    mov rax, 0x1111111122222222
    cmp r8,  rax
    jne .fail

    ; Verify stack is balanced (RSP restored)
    cmp r14, r12
    jne .fail

    mov rdi, ok_msg
    mov rsi, ok_len
    call write_buf
    xor edi, edi                 ; exit(0)
    jmp do_exit

.fail:
    mov rdi, fail_msg
    mov rsi, fail_len
    call write_buf
    mov edi, 1                   ; exit(1)

do_exit:
    mov eax, 60                  ; SYS_exit
    syscall

; -------------------------
; write_buf(rdi=ptr, rsi=len)
; clobbers: rax, rdi, rsi, rdx
; -------------------------
write_buf:
    mov eax, 1                   ; SYS_write
    mov edi, 1                   ; fd=stdout
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

; -------------------------
; print_hex64(rax=value)
; prints exactly 16 hex digits + '\n' to stdout
; clobbers: rax, rcx, rdx, rsi, rdi, r8, r9
; -------------------------
print_hex64:
    lea rdi, [rel hexbuf]
    mov rcx, 16
    lea r8,  [rel hex_digits]

.loop:
    ; take highest nibble first
    mov rdx, rax
    shr rdx, 60
    mov dl, [r8 + rdx]
    mov [rdi], dl
    inc rdi
    shl rax, 4
    dec rcx
    jnz .loop

    mov byte [rdi], 10           ; '\n'

    lea rdi, [rel hexbuf]
    mov rsi, 17
    jmp write_buf
