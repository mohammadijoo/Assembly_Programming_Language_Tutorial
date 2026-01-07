    ; Chapter 3 - Lesson 4 (Working with Constants)
    ; Example 2: Immediate constants, sign-extension, and zero-extension (x86-64)

    global _start

    section .data
    hexdigits   db "0123456789ABCDEF"
    hexbuf      db "0x0000000000000000", 10
    hexbuf_len  equ $ - hexbuf

    hdr         db "Immediate constants: how the CPU interprets the same bit pattern", 10
    hdr_len     equ $ - hdr

    lbl1        db "mov eax, -1  (32-bit write zero-extends into rax):", 10
    lbl1_len    equ $ - lbl1

    lbl2        db "mov rax, -1  (64-bit value, all bits set):", 10
    lbl2_len    equ $ - lbl2

    lbl3        db "add rax, byte -1 (imm8 is sign-extended by the instruction):", 10
    lbl3_len    equ $ - lbl3

    section .text
    ; --- minimal I/O helpers (Linux x86-64 syscalls) ---
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

; write(fd=FD_STDOUT, buf=RSI, len=RDX)
%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

; exit(code=EDI)
%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

; print_hex64:
;   in : RAX = value
;   out: writes "0x" + 16 hex digits + "\n"
; clobbers: RAX,RBX,RCX,RDI,RSI,RDX
print_hex64:
    mov rbx, rax
    lea rdi, [rel hexbuf + 2 + 15]   ; last hex digit position
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [rel hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop

    lea rsi, [rel hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

_start:
    lea rsi, [rel hdr]
    mov edx, hdr_len
    write_stdout

    ; Case 1: 32-bit register write implies zero-extension to 64-bit register
    lea rsi, [rel lbl1]
    mov edx, lbl1_len
    write_stdout

    mov eax, -1          ; EAX = 0xFFFFFFFF, but upper 32 bits of RAX become 0
    call print_hex64

    ; Case 2: 64-bit constant
    lea rsi, [rel lbl2]
    mov edx, lbl2_len
    write_stdout

    mov rax, -1          ; RAX = 0xFFFFFFFFFFFFFFFF
    call print_hex64

    ; Case 3: imm8 sign-extension in arithmetic instructions
    lea rsi, [rel lbl3]
    mov edx, lbl3_len
    write_stdout

    xor eax, eax         ; RAX = 0
    add rax, byte -1     ; adds 0xFF sign-extended to 64-bit -> -1
    call print_hex64

    xor edi, edi
    exit
