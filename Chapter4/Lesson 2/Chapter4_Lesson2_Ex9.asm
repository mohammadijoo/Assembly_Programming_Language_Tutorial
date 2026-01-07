; Chapter 4 - Lesson 2 (Logical Instructions): Exercise 2 Solution
; XOR stream cipher (educational):
;   c[i] = p[i] XOR key[i mod keylen]
; Decryption is identical: p[i] = c[i] XOR key[i mod keylen]

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

plaintext db "XOR-based cipher demo (NOT secure, educational).",10
pt_len equ $-plaintext

key db "K3y!"
key_len equ $-key

msg0 db "Plaintext:",10,0
len_msg0 equ $-msg0
msg1 db "Ciphertext (hex):",10,0
len_msg1 equ $-msg1
msg2 db "Decrypted:",10,0
len_msg2 equ $-msg2

SECTION .bss
cipher resb pt_len
hex2   resb 2
SECTION .text

write_stdout:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

; print raw buffer: RSI=ptr, RDX=len
print_buf:
    call write_stdout
    ret

; print one byte in AL as 2 hex chars (no newline)
print_hex_byte:
    mov bl, al
    shr bl, 4
    and bl, 0xF
    mov bl, [hex_digits+rbx]
    mov [hex2+0], bl

    mov bl, al
    and bl, 0xF
    mov bl, [hex_digits+rbx]
    mov [hex2+1], bl

    lea rsi, [hex2]
    mov rdx, 2
    call write_stdout
    ret

_start:
    ; Print plaintext
    lea rsi, [msg0]
    mov rdx, len_msg0
    call write_stdout

    lea rsi, [plaintext]
    mov rdx, pt_len
    call print_buf

    ; Encrypt: cipher[i] = plaintext[i] XOR key[i % key_len]
    xor rcx, rcx          ; i
    xor r8, r8            ; key index
.enc_loop:
    mov al, [plaintext+rcx]
    mov bl, [key+r8]
    xor al, bl
    mov [cipher+rcx], al

    inc rcx
    inc r8
    cmp r8, key_len
    jb .no_wrap
    xor r8, r8
.no_wrap:
    cmp rcx, pt_len
    jb .enc_loop

    ; Print ciphertext hex
    lea rsi, [msg1]
    mov rdx, len_msg1
    call write_stdout

    xor rcx, rcx
.print_hex_loop:
    mov al, [cipher+rcx]
    call print_hex_byte
    ; print a space after each byte
    mov al, ' '
    lea rsi, [rsp-1]
    mov [rsp-1], al
    mov rdx, 1
    call write_stdout

    inc rcx
    cmp rcx, pt_len
    jb .print_hex_loop

    ; newline
    mov al, 10
    mov [rsp-1], al
    lea rsi, [rsp-1]
    mov rdx, 1
    call write_stdout

    ; Decrypt in-place back into cipher: cipher[i] ^= key[i % key_len]
    xor rcx, rcx
    xor r8, r8
.dec_loop:
    mov al, [cipher+rcx]
    xor al, [key+r8]
    mov [cipher+rcx], al
    inc rcx
    inc r8
    cmp r8, key_len
    jb .no_wrap2
    xor r8, r8
.no_wrap2:
    cmp rcx, pt_len
    jb .dec_loop

    ; Print decrypted
    lea rsi, [msg2]
    mov rdx, len_msg2
    call write_stdout

    lea rsi, [cipher]
    mov rdx, pt_len
    call print_buf

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
