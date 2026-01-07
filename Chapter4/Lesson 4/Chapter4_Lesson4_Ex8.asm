; Chapter4_Lesson4_Ex8.asm
; Exercise (Very Hard): 128-bit rotate-left by k (0..127) using only shifts and OR.
; Representation: value = (HI:RDx, LO:RAx). Output in RDX:RAX.
; We avoid shifts by 64 by special-casing k==0 and k==64.
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg0 db "Input HI = 0x",0
msg1 db "Input LO = 0x",0
msg2 db "k       = 0x",0
msg3 db "Out   HI = 0x",0
msg4 db "Out   LO = 0x",0

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

; rotl128:
;   RDX:RAX = input (HI:LO)
;   ECX     = k (0..127); only low 8 bits used, then masked to 0..127
; returns:
;   RDX:RAX = rotated left by k
rotl128:
    push rbx
    push rsi
    push rdi
    mov esi, ecx
    and esi, 127
    jz .done

    cmp esi, 64
    jb .lt64
    sub esi, 64
    xchg rax, rdx       ; rotate by 64 is just swapping halves
    jz .done            ; k==64 exactly

.lt64:
    ; now k in 1..63
    mov rdi, rax        ; save LO
    mov rbx, rdx        ; save HI

    mov ecx, esi        ; k
    mov rax, rdi
    mov cl, cl
    shl rax, cl         ; LO << k

    mov edx, 64
    sub edx, ecx        ; 64-k
    mov cl, dl
    mov rsi, rbx
    shr rsi, cl         ; HI >> (64-k)
    or rax, rsi         ; new LO

    ; new HI = (HI<<k) | (LO>>(64-k))
    mov ecx, esi
    mov rdx, rbx
    mov cl, cl
    shl rdx, cl

    mov ecx, esi
    mov edx, 64
    sub edx, ecx
    mov cl, dl
    mov rsi, rdi
    shr rsi, cl
    or rdx, rsi

.done:
    pop rdi
    pop rsi
    pop rbx
    ret

_start:
    mov rdx, 0x0123456789ABCDEF
    mov rax, 0x0F1E2D3C4B5A6978
    mov ecx, 77

    lea rsi, [rel msg0]
    call print_cstr
    mov rax, rdx
    call print_hex64

    lea rsi, [rel msg1]
    call print_cstr
    mov rax, 0x0F1E2D3C4B5A6978
    call print_hex64

    lea rsi, [rel msg2]
    call print_cstr
    movzx rax, ecx
    call print_hex64

    mov rdx, 0x0123456789ABCDEF
    mov rax, 0x0F1E2D3C4B5A6978
    call rotl128

    lea rsi, [rel msg3]
    call print_cstr
    mov rax, rdx
    call print_hex64

    lea rsi, [rel msg4]
    call print_cstr
    ; LO already in RAX
    call print_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
