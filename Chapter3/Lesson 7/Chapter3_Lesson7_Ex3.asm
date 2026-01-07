bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 3
; "Extended ASCII" and code-page ambiguity:
; we do not trust rendering; we print bytes and indices deterministically.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    intro:      db "Bytes 0x00..0xFF are bytes. Interpretation depends on encoding.", 10
    intro_len:  equ $ - intro

    sample:     db 0x41, 0x7F, 0x80, 0x9F, 0xE9, 0xFF, 10
    sample_len: equ $ - sample

    hex_lut:    db "0123456789ABCDEF"
    tag:        db "Index:Byte  ", 10
    tag_len:    equ $ - tag

section .bss
    line:       resb 32

section .text

_start:
    ; Print intro
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [intro]
    mov edx, intro_len
    syscall

    ; Print header
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [tag]
    mov edx, tag_len
    syscall

    ; For each sample byte: print "ii:HH\n"
    xor ecx, ecx                ; index
    lea rbx, [sample]

.loop:
    cmp ecx, sample_len
    jae .done

    mov al, cl
    call u8_to_hex2             ; writes 2 digits at line[0..1]
    mov byte [line+2], ':'

    mov al, [rbx + rcx]
    call byte_to_hex2_at3       ; writes 2 digits at line[3..4]

    mov byte [line+5], 10

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [line]
    mov edx, 6
    syscall

    inc ecx
    jmp .loop

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall

; line layout: [0][1] index hex, [2]=':', [3][4] byte hex, [5]='\n'

u8_to_hex2:
    lea r8, [hex_lut]
    mov ah, al
    shr al, 4
    and ah, 0x0F
    movzx eax, al
    mov dl, [r8 + rax]
    mov [line], dl
    movzx eax, ah
    mov dl, [r8 + rax]
    mov [line+1], dl
    ret

byte_to_hex2_at3:
    lea r8, [hex_lut]
    mov ah, al
    shr al, 4
    and ah, 0x0F
    movzx eax, al
    mov dl, [r8 + rax]
    mov [line+3], dl
    movzx eax, ah
    mov dl, [r8 + rax]
    mov [line+4], dl
    ret
