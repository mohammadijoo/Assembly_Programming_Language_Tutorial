; Chapter3_Lesson10_Ex11.asm
; Programming Exercise 3 (Solution):
; IPv4 Flags+FragmentOffset field (16 bits):
;   bits [15:13] flags (3)  : 0=reserved, 1=DF, 2=MF (as bits within this 3-bit field)
;   bits [12:0]  offset (13)
;
; This demo treats the 16-bit word in host order (little-endian register value).
; Real networking code must also handle network byte order.
;
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex11.asm && ld -o ex11 Chapter3_Lesson10_Ex11.o
; Run:      ./ex11

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_word:  db "word     = ",0
msg_flags: db "flags    = ",0
msg_off:   db "offset   = ",0
msg_new:   db "word(new)= ",0

hexdigits: db "0123456789ABCDEF"

SECTION .bss
hexbuf: resb 19

SECTION .text

write_buf:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

print_cstr:
    xor rdx, rdx
.count:
    cmp byte [rsi+rdx], 0
    je .go
    inc rdx
    jmp .count
.go:
    jmp write_buf

print_hex64:
    lea rsi, [rel hexbuf]
    mov byte [rsi+0], '0'
    mov byte [rsi+1], 'x'
    mov rax, rdi
    lea rbx, [rel hexdigits]
    mov rcx, 16
.loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx+rdx]
    mov [rsi+1+rcx], dl
    shr rax, 4
    dec rcx
    jnz .loop
    mov byte [rsi+18], 10
    mov rdx, 19
    jmp write_buf

_start:
    ; Example: flags=0b010 (DF set), offset=0x0123
    ; word = (flags<<13) | offset
    mov eax, 0x0123
    mov ebx, 0b010
    shl ebx, 13
    or  eax, ebx
    movzx edi, ax

    lea rsi, [rel msg_word]
    call print_cstr
    call print_hex64

    ; Extract flags: (word >> 13) & 0x7
    mov edx, edi
    shr edx, 13
    and edx, 0x7
    lea rsi, [rel msg_flags]
    call print_cstr
    mov edi, rdx
    call print_hex64

    ; Extract offset: word & 0x1FFF
    mov edx, edi
    and edx, 0x1FFF
    lea rsi, [rel msg_off]
    call print_cstr
    mov edi, rdx
    call print_hex64

    ; Update: set MF bit (flags bit0 in this 3-bit field) and offset=0x0ABC
    mov ax, 0
    ; insert offset
    mov bx, 0x0ABC
    and bx, 0x1FFF
    or ax, bx
    ; insert flags
    mov bx, 0b011            ; DF+MF
    and bx, 0x7
    shl bx, 13
    or ax, bx

    movzx edi, ax
    lea rsi, [rel msg_new]
    call print_cstr
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
