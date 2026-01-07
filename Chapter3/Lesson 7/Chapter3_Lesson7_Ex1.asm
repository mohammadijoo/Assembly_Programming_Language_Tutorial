bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 1
; ASCII bytes in memory + printing + hex dump using Linux syscalls (x86-64)

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg:        db "ASCII demo: Hello, NASM!", 10, 0
    msg_len:    equ $ - msg - 1          ; exclude the terminating 0

    hex_lut:    db "0123456789ABCDEF"
    nl:         db 10

section .bss
    hexbuf:     resb 4   ; "HH " (3 bytes used)

section .text

_start:
    ; Print the message bytes (excluding the 0 terminator).
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [msg]
    mov edx, msg_len
    syscall

    ; Dump the message bytes as hex: each byte -> "HH "
    lea rbx, [msg]
    mov ecx, msg_len

.hex_loop:
    test ecx, ecx
    jz .done_hex

    mov al, byte [rbx]
    call print_hex_byte_sp

    inc rbx
    dec ecx
    jmp .hex_loop

.done_hex:
    ; newline
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [nl]
    mov edx, 1
    syscall

    ; Exit(0)
    xor edi, edi
    mov eax, SYS_exit
    syscall

; --------------------------------------------
; print_hex_byte_sp
; IN:  AL = byte to print
; OUT: writes 3 bytes: two hex digits + space
; Clobbers: rax, rdi, rsi, rdx, r8, r9
; --------------------------------------------
print_hex_byte_sp:
    lea r8, [hex_lut]
    mov r9b, al

    ; high nibble
    mov al, r9b
    shr al, 4
    movzx eax, al
    mov dl, byte [r8 + rax]
    mov byte [hexbuf], dl

    ; low nibble
    mov al, r9b
    and al, 0x0F
    movzx eax, al
    mov dl, byte [r8 + rax]
    mov byte [hexbuf + 1], dl

    mov byte [hexbuf + 2], ' '

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [hexbuf]
    mov edx, 3
    syscall
    ret
