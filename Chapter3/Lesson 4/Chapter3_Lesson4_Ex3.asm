; Chapter 3 - Lesson 4 (Working with Constants)
; Example 3: Character and multi-character constants (and byte order)

global _start

section .data
hexdigits     db "0123456789ABCDEF"

hexbuf        db "0x0000000000000000", 10
hexbuf_len    equ $ - hexbuf

bbuf          db "00 ", 0
bbuf_len      equ 3

hdr           db "NASM character constants: 'A', 'AB', 'ABCD' ...", 10
hdr_len       equ $ - hdr

note          db "Note: multi-character constants pack bytes into an integer (little-endian).", 10
note_len      equ $ - note

; constants evaluated by the assembler
C1            equ 'A'          ; 0x41
C2            equ 'AB'         ; two bytes packed into a word
C4            equ 'ABCD'       ; four bytes packed into a dword

packed_dword  dd C4

section .text
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

; print_hex64: RAX -> "0x" + 16 hex digits + "\n"
print_hex64:
    push rbx
    push rcx
    push rdi
    mov rbx, rax
    lea rdi, [rel hexbuf + 2 + 15]
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
    pop rdi
    pop rcx
    pop rbx
    ret

; print_hex8: AL -> "HH " (3 bytes)
print_hex8:
    push rax
    push rbx
    mov bl, al

    ; high nibble
    mov al, bl
    shr al, 4
    and eax, 0xF
    mov al, [rel hexdigits + rax]
    mov [rel bbuf + 0], al

    ; low nibble
    mov al, bl
    and eax, 0xF
    mov al, [rel hexdigits + rax]
    mov [rel bbuf + 1], al

    lea rsi, [rel bbuf]
    mov edx, bbuf_len
    write_stdout

    pop rbx
    pop rax
    ret

_start:
    lea rsi, [rel hdr]
    mov edx, hdr_len
    write_stdout

    mov rax, C1
    call print_hex64

    mov rax, C2
    call print_hex64

    mov rax, C4
    call print_hex64

    lea rsi, [rel note]
    mov edx, note_len
    write_stdout

    ; Dump the bytes of packed_dword to make endianness visible
    mov ecx, 4
    lea rbx, [rel packed_dword]
.dump_loop:
    mov al, [rbx]
    call print_hex8
    inc rbx
    loop .dump_loop

    ; newline
    mov byte [rel bbuf + 0], 10
    mov byte [rel bbuf + 1], 0
    lea rsi, [rel bbuf]
    mov edx, 1
    write_stdout

    xor edi, edi
    exit
