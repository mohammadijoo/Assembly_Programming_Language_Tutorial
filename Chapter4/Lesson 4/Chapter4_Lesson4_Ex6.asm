; Chapter4_Lesson4_Ex6.asm
; Manual rotate-left for 64-bit values using SHL/SHR/OR, compared to ROL.
; Highlights: must avoid shifting by 64; normalize count; consider flags/clobbers.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "x                 = 0x",0
msg2 db "k                 = 0x",0
msg3 db "ROL x, k          = 0x",0
msg4 db "manual rotl(x, k) = 0x",0
msg5 db "If k==0, manual formula must not perform a shift by 64.",10,0

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

; rotl64_manual:
;   RDI = x
;   RSI = k (only low byte used)
; returns:
;   RAX = (x <<< (k mod 64)) using SHL/SHR/OR
rotl64_manual:
    movzx ecx, sil
    and ecx, 63
    jz .k0
    mov rax, rdi
    mov rbx, rdi
    mov cl, cl          ; k in CL
    shl rax, cl         ; left part

    mov edx, 64
    sub edx, ecx        ; edx = 64 - k (1..63)
    mov cl, dl
    shr rbx, cl         ; right part

    or rax, rbx
    ret
.k0:
    mov rax, rdi
    ret

_start:
    mov rdi, 0x0123456789ABCDEF
    mov rsi, 13

    lea rsi, [rel msg1]
    call print_cstr
    mov rax, rdi
    call print_hex64

    lea rsi, [rel msg2]
    call print_cstr
    mov rax, 13
    call print_hex64

    lea rsi, [rel msg3]
    call print_cstr
    mov rax, rdi
    mov cl, 13
    rol rax, cl
    call print_hex64

    lea rsi, [rel msg4]
    call print_cstr
    mov rdi, 0x0123456789ABCDEF
    mov rsi, 13
    call rotl64_manual
    call print_hex64

    lea rsi, [rel msg5]
    call print_cstr

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
