bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 2
; ASCII case conversion: safe range-check vs fast bit trick.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    src:        db "AsSeMbLy 101: aZ[]_~", 10, 0
    src_len:    equ $ - src - 1

    label1:     db "Original: ", 0
    label1_len: equ $ - label1 - 1

    label2:     db "Lower(safe): ", 0
    label2_len: equ $ - label2 - 1

    label3:     db "Upper(safe): ", 0
    label3_len: equ $ - label3 - 1

    label4:     db "Lower(fast, unsafe): ", 0
    label4_len: equ $ - label4 - 1

section .bss
    buf1:       resb 64
    buf2:       resb 64
    buf3:       resb 64

section .text

_start:
    ; Print Original:
    lea rdi, [label1]
    mov edx, label1_len
    call write_stdout

    lea rsi, [src]
    mov edx, src_len
    call write_stdout

    ; Lower(safe):
    lea rdi, [label2]
    mov edx, label2_len
    call write_stdout

    lea rsi, [src]
    lea rdi, [buf1]
    mov ecx, src_len
    call ascii_tolower_safe

    lea rsi, [buf1]
    mov edx, src_len
    call write_stdout

    ; Upper(safe):
    lea rdi, [label3]
    mov edx, label3_len
    call write_stdout

    lea rsi, [src]
    lea rdi, [buf2]
    mov ecx, src_len
    call ascii_toupper_safe

    lea rsi, [buf2]
    mov edx, src_len
    call write_stdout

    ; Lower(fast, unsafe):
    lea rdi, [label4]
    mov edx, label4_len
    call write_stdout

    lea rsi, [src]
    lea rdi, [buf3]
    mov ecx, src_len
    call ascii_tolower_fast_unsafe

    lea rsi, [buf3]
    mov edx, src_len
    call write_stdout

    ; exit
    xor edi, edi
    mov eax, SYS_exit
    syscall

; --------------------------------------------
; write_stdout
; IN: rdi=ptr, edx=len
; --------------------------------------------
write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    mov rsi, rdi
    syscall
    ret

; --------------------------------------------
; ascii_tolower_safe
; Converts only 'A'..'Z' to 'a'..'z'
; IN:  rsi=src, rdi=dst, ecx=len
; --------------------------------------------
ascii_tolower_safe:
    test ecx, ecx
    jz .done
.loop:
    mov al, [rsi]
    cmp al, 'A'
    jb .store
    cmp al, 'Z'
    ja .store
    or  al, 0x20              ; set bit 5: 'A'(0x41) -> 'a'(0x61)
.store:
    mov [rdi], al
    inc rsi
    inc rdi
    dec ecx
    jnz .loop
.done:
    ret

; --------------------------------------------
; ascii_toupper_safe
; Converts only 'a'..'z' to 'A'..'Z'
; --------------------------------------------
ascii_toupper_safe:
    test ecx, ecx
    jz .done
.loop:
    mov al, [rsi]
    cmp al, 'a'
    jb .store
    cmp al, 'z'
    ja .store
    and al, 0xDF              ; clear bit 5: 'a'(0x61) -> 'A'(0x41)
.store:
    mov [rdi], al
    inc rsi
    inc rdi
    dec ecx
    jnz .loop
.done:
    ret

; --------------------------------------------
; ascii_tolower_fast_unsafe
; Applies OR 0x20 to every byte.
; This corrupts punctuation in the range 0x40..0x5F (e.g., '[' -> '{').
; --------------------------------------------
ascii_tolower_fast_unsafe:
    test ecx, ecx
    jz .done
.loop:
    mov al, [rsi]
    or  al, 0x20
    mov [rdi], al
    inc rsi
    inc rdi
    dec ecx
    jnz .loop
.done:
    ret
