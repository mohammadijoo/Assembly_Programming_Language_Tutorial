; Chapter3_Lesson10_Ex1.asm
; Bitfield extraction with shift+mask (packed 32-bit header)
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex1.asm && ld -o ex1 Chapter3_Lesson10_Ex1.o
; Run:      ./ex1

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
; Header layout (bit positions):
; [31:24]=flags (8) | [23:12]=length (12) | [11:4]=type (8) | [3:0]=version (4)
header32: dd 0xA5C3E21B

msg_hdr:     db "header32 = ",0
len_msg_hdr: equ $-msg_hdr
msg_ver:     db "version  = ",0
len_msg_ver: equ $-msg_ver
msg_type:    db "type     = ",0
len_msg_type: equ $-msg_type
msg_len:     db "length   = ",0
len_msg_len: equ $-msg_len
msg_flags:   db "flags    = ",0
len_msg_flags: equ $-msg_flags
nl:          db 10

hexdigits: db "0123456789ABCDEF"

SECTION .bss
hexbuf: resb 19            ; "0x" + 16 hex + "\n"  -> 19 bytes

SECTION .text

;--------------------------------------------
; write_buf(rsi=ptr, rdx=len)
;--------------------------------------------
write_buf:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

;--------------------------------------------
; print_cstr(rsi=ptr) -- prints until 0 byte
; clobbers: rax, rdi, rdx
;--------------------------------------------
print_cstr:
    xor rdx, rdx
.count:
    cmp byte [rsi+rdx], 0
    je .go
    inc rdx
    jmp .count
.go:
    jmp write_buf

;--------------------------------------------
; print_hex64(rdi=value)
; Produces: 0xXXXXXXXXXXXXXXXX\n
;--------------------------------------------
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
    mov [rsi+1+rcx], dl     ; fill from rightmost digit
    shr rax, 4
    dec rcx
    jnz .loop

    mov byte [rsi+18], 10
    mov rdx, 19
    jmp write_buf

_start:
    ; Load packed header
    mov eax, dword [rel header32]
    mov edi, rax

    ; Print header
    lea rsi, [rel msg_hdr]
    call print_cstr
    call print_hex64

    ; version = (header >> 0) & 0xF
    mov ecx, eax
    and ecx, 0xF
    lea rsi, [rel msg_ver]
    call print_cstr
    mov edi, rcx
    call print_hex64

    ; type = (header >> 4) & 0xFF
    mov edx, eax
    shr edx, 4
    and edx, 0xFF
    lea rsi, [rel msg_type]
    call print_cstr
    mov edi, rdx
    call print_hex64

    ; length = (header >> 12) & 0xFFF
    mov r8d, eax
    shr r8d, 12
    and r8d, 0xFFF
    lea rsi, [rel msg_len]
    call print_cstr
    mov edi, r8
    call print_hex64

    ; flags = (header >> 24) & 0xFF
    mov r9d, eax
    shr r9d, 24
    and r9d, 0xFF
    lea rsi, [rel msg_flags]
    call print_cstr
    mov edi, r9
    call print_hex64

    ; exit(0)
    xor edi, edi
    mov eax, SYS_exit
    syscall
