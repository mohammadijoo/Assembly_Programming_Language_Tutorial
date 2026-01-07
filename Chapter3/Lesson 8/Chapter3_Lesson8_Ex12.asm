BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Very hard exercise solution:
; Minimal hexdump: offset + 16 bytes (hex) + ASCII side.

section .rodata
hdr db "hexdump (offset: bytes | ascii)",10,0
pipe db " | ",0
spc  db " ",0

section .bss
hex2     resb 2
off8     resb 8
ascii16  resb 16

section .data
buf_len equ 64
buf:
%assign i 0
%rep buf_len
    db i
%assign i i+1
%endrep

section .text
global _start

; -----------------------------------------------------------------------------
; print_hex32_fixed8
;   edi = 32-bit value
;   prints exactly 8 hex digits (no prefix)
; -----------------------------------------------------------------------------
print_hex32_fixed8:
    push rbx
    mov eax, edi
    lea rbx, [off8]
    mov rcx, 8
    lea rsi, [rbx+7]
.loop:
    mov edx, eax
    and edx, 0x0F
    mov dl, [hex_digits+rdx]
    mov [rsi], dl
    dec rsi
    shr eax, 4
    dec rcx
    jnz .loop

    mov rdi, STDOUT
    lea rsi, [off8]
    mov rdx, 8
    call write_buf

    pop rbx
    ret

; -----------------------------------------------------------------------------
; byte_to_printable
;   al = byte
;   returns al printable ASCII or '.' if outside [0x20..0x7E]
; -----------------------------------------------------------------------------
byte_to_printable:
    cmp al, 0x20
    jb .dot
    cmp al, 0x7E
    ja .dot
    ret
.dot:
    mov al, '.'
    ret

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    xor r12d, r12d          ; offset
.outer:
    ; print offset as 8 hex digits
    mov edi, r12d
    call print_hex32_fixed8

    ; print ": "
    mov byte [tmp_digits], ':'
    mov byte [tmp_digits+1], ' '
    mov rdi, STDOUT
    lea rsi, [tmp_digits]
    mov rdx, 2
    call write_buf

    ; 16 bytes per line
    xor r13d, r13d
.inner:
    mov al, [buf+r12+r13]
    mov dil, al
    lea rsi, [hex2]
    call hexbyte_to_ascii

    mov rdi, STDOUT
    lea rsi, [hex2]
    mov rdx, 2
    call write_buf

    mov rdi, STDOUT
    lea rsi, [spc]
    call print_cstr

    ; ascii side buffer
    mov al, [buf+r12+r13]
    call byte_to_printable
    mov [ascii16+r13], al

    inc r13d
    cmp r13d, 16
    jb .inner

    mov rdi, STDOUT
    lea rsi, [pipe]
    call print_cstr

    ; print 16 ASCII chars
    mov rdi, STDOUT
    lea rsi, [ascii16]
    mov rdx, 16
    call write_buf

    call print_nl

    add r12d, 16
    cmp r12d, buf_len
    jb .outer

    mov eax, SYS_exit
    xor edi, edi
    syscall
