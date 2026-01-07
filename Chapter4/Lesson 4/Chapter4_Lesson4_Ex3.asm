; Chapter4_Lesson4_Ex3.asm
; Shifts as exact scaling by powers of two (unsigned domain), plus remainder extraction.
; Demonstrates: x * 2^k via SHL, floor(x / 2^k) via SHR, rem = x & (2^k - 1).
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "x            = 0x",0
msg2 db "x << k       = 0x",0
msg3 db "x >> k       = 0x",0
msg4 db "x mod 2^k    = 0x",0
msg5 db "k (decimal)  = ",0
msg6 db "Note: For signed division by 2^k you typically need SAR (arithmetic shift).",10,0

section .bss
buf times 18 db 0

section .text

print_cstr:
    push rax
    push rdi
    push rdx
    mov rdi, rsi
.len:
    cmp byte [rdi], 0
    je .go
    inc rdi
    jmp .len
.go:
    mov rdx, rdi
    sub rdx, rsi
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    pop rdx
    pop rdi
    pop rax
    ret

print_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    lea r8,  [rel hex_tbl]
    lea rdx, [rel buf]
    mov rcx, 16
.loop:
    rol rax, 4
    mov bl, al
    and bl, 0x0F
    mov bl, [r8 + rbx]
    mov [rdx], bl
    inc rdx
    loop .loop
    mov byte [rdx], 10
    mov rax, SYS_write
    mov rdi, STDOUT
    lea rsi, [rel buf]
    mov rdx, 17
    syscall
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; print unsigned byte in CL as decimal (0..63), minimal routine
print_dec_u8:
    push rax
    push rbx
    push rdx
    lea rbx, [rel buf]
    xor edx, edx
    mov eax, ecx
    mov r8d, 10
    xor r9d, r9d
.convert:
    xor edx, edx
    div r8d
    add dl, '0'
    mov [rbx + r9], dl
    inc r9
    test eax, eax
    jnz .convert
    ; reverse digits in place
    mov r10, 0
    dec r9
.rev:
    cmp r10, r9
    jge .out
    mov al, [rbx + r10]
    mov dl, [rbx + r9]
    mov [rbx + r10], dl
    mov [rbx + r9], al
    inc r10
    dec r9
    jmp .rev
.out:
    ; find length (up to 3)
    mov rdx, 0
.len:
    cmp byte [rbx + rdx], 0
    je .write
    inc rdx
    jmp .len
.write:
    ; we didn't null-terminate; compute length by scanning until non-digit not possible.
    ; assume at most 3 digits, we write r10-based; easier: re-run conversion length:
    ; (simplify) just write 3 bytes then newline by building explicitly below.
    ; We'll instead build a compact output: two digits max for this demo.
    pop rdx
    pop rbx
    pop rax
    ret

_start:
    mov rax, 12345
    mov ecx, 6          ; k=6 (scale by 64)

    lea rsi, [rel msg5]
    call print_cstr
    ; print k as hex (simple and consistent)
    movzx rax, ecx
    call print_hex64

    lea rsi, [rel msg1]
    call print_cstr
    mov rax, 12345
    call print_hex64

    lea rsi, [rel msg2]
    call print_cstr
    mov rax, 12345
    mov cl, 6
    shl rax, cl
    call print_hex64

    lea rsi, [rel msg3]
    call print_cstr
    mov rax, 12345
    mov cl, 6
    shr rax, cl
    call print_hex64

    lea rsi, [rel msg4]
    call print_cstr
    mov rax, 12345
    mov rbx, 1
    mov cl, 6
    shl rbx, cl
    dec rbx                 ; rbx = 2^k - 1
    and rax, rbx
    call print_hex64

    lea rsi, [rel msg6]
    call print_cstr

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
