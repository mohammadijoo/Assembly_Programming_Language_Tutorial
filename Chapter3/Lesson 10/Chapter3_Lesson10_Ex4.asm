; Chapter3_Lesson10_Ex4.asm
; Packing and unpacking RGB565 (5-6-5) into a 16-bit word.
; Demonstrates disciplined masking on insert, and shift+mask on extract.
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex4.asm && ld -o ex4 Chapter3_Lesson10_Ex4.o
; Run:      ./ex4

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_pack:  db "RGB565 packed = ",0
msg_r:     db "R (5 bits)    = ",0
msg_g:     db "G (6 bits)    = ",0
msg_b:     db "B (5 bits)    = ",0

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
    ; Example components (already within range, but we mask anyway)
    mov eax, 0x1F            ; R in [0..31]
    mov ebx, 0x2A            ; G in [0..63]
    mov ecx, 0x0C            ; B in [0..31]

    ; Mask and pack: packed = (R&0x1F)<<11 | (G&0x3F)<<5 | (B&0x1F)
    and eax, 0x1F
    and ebx, 0x3F
    and ecx, 0x1F
    shl eax, 11
    shl ebx, 5
    or eax, ebx
    or eax, ecx
    movzx edi, ax            ; packed in DI (zero-extend 16-bit)

    lea rsi, [rel msg_pack]
    call print_cstr
    call print_hex64

    ; Unpack:
    ; R = (packed >> 11) & 0x1F
    mov edx, edi
    shr edx, 11
    and edx, 0x1F
    lea rsi, [rel msg_r]
    call print_cstr
    mov edi, rdx
    call print_hex64

    ; G = (packed >> 5) & 0x3F
    mov edx, edi
    shr edx, 5
    and edx, 0x3F
    lea rsi, [rel msg_g]
    call print_cstr
    mov edi, rdx
    call print_hex64

    ; B = packed & 0x1F
    mov edx, edi
    and edx, 0x1F
    lea rsi, [rel msg_b]
    call print_cstr
    mov edi, rdx
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
