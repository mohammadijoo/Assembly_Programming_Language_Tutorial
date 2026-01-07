    ; Chapter 3 - Lesson 4 (Working with Constants)
    ; Example 1: Numeric constants and NASM literal notation (Linux x86-64)

    global _start

    section .data
    hexdigits   db "0123456789ABCDEF"
    hexbuf      db "0x0000000000000000", 10
    hexbuf_len  equ $ - hexbuf

    msg1        db "Constants in different bases that evaluate to the same value:", 10
    msg1_len    equ $ - msg1

    ; --- Numeric literal forms (all represent 123 decimal) ---
    C_DEC       equ 123
    C_HEX       equ 0x7B
    C_BIN       equ 1111011b

    ; NASM also supports separators (readability):
    C_BIG       equ 0xDEAD_BEEF_CAFE_BABE

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
    ; Print intro message
    lea rsi, [rel msg1]
    mov edx, msg1_len
    write_stdout

    ; Print the three equivalent constants (should match)
    mov rax, C_DEC
    call print_hex64

    mov rax, C_HEX
    call print_hex64

    mov rax, C_BIN
    call print_hex64

    ; Print a large constant with separators
    mov rax, C_BIG
    call print_hex64

    xor edi, edi
    exit
