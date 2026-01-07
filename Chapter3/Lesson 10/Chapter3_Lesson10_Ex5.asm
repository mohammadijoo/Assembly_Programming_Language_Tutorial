; Chapter3_Lesson10_Ex5.asm
; Rotate-based extraction for wrap-around bitfields.
; Scenario: a 16-bit word has an 8-bit field that wraps: bits [15:12] and [3:0].
; We want field = (high_nibble << 4) | low_nibble.
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex5.asm && ld -o ex5 Chapter3_Lesson10_Ex5.o
; Run:      ./ex5

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_x:     db "x        = ",0
msg_field: db "field8   = ",0
msg_alt:   db "alt8     = ",0

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
    mov ax, 0xABCD          ; x = 0xABCD, high nibble=A, low nibble=D
    movzx edi, ax
    lea rsi, [rel msg_x]
    call print_cstr
    call print_hex64

    ; Method 1: isolate and combine explicitly
    ; high = (x >> 12) & 0xF, low = x & 0xF, field = (high<<4)|low
    mov bx, ax
    mov cx, ax
    shr bx, 12
    and bx, 0x000F
    and cx, 0x000F
    shl bx, 4
    or  bx, cx
    movzx edi, bx
    lea rsi, [rel msg_field]
    call print_cstr
    call print_hex64

    ; Method 2: rotate so the wrap-around field becomes contiguous in bits [7:0]
    ; If we rotate left by 4: ROL(x,4) => low nibble moves into high nibble position.
    ; After ROL 4, the low byte is: (low_nibble << 4) | high_nibble.
    mov bx, ax
    rol bx, 4
    and bx, 0x00FF
    movzx edi, bx
    lea rsi, [rel msg_alt]
    call print_cstr
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
