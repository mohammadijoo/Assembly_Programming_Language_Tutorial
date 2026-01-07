%ifndef CH3_L8_NUMIO
%define CH3_L8_NUMIO 1

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define STDIN   0
%define STDOUT  1
%define STDERR  2

section .rodata
hex_digits db "0123456789ABCDEF"
nl         db 10

section .bss
tmp_digits resb 80           ; scratch buffer for base conversion
hexbuf     resb 18           ; "0x" + 16 digits
binbuf     resb 66           ; "0b" + 64 bits

section .text

; -----------------------------------------------------------------------------
; write_buf
;   rdi = fd, rsi = buf, rdx = len
; -----------------------------------------------------------------------------
write_buf:
    mov eax, SYS_write
    syscall
    ret

; -----------------------------------------------------------------------------
; strlen
;   rsi = NUL-terminated string
;   returns rax = length (bytes before NUL)
; -----------------------------------------------------------------------------
strlen:
    xor eax, eax
.loop:
    cmp byte [rsi+rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; -----------------------------------------------------------------------------
; print_cstr
;   rdi = fd, rsi = NUL-terminated string
; -----------------------------------------------------------------------------
print_cstr:
    push rdi
    push rsi
    call strlen
    mov rdx, rax
    pop rsi
    pop rdi
    jmp write_buf

; -----------------------------------------------------------------------------
; print_nl
;   prints newline to STDOUT
; -----------------------------------------------------------------------------
print_nl:
    mov rdi, STDOUT
    lea rsi, [nl]
    mov rdx, 1
    jmp write_buf

; -----------------------------------------------------------------------------
; hexbyte_to_ascii
;   dil = byte value
;   rsi = pointer to 2-byte output buffer (no NUL)
; -----------------------------------------------------------------------------
hexbyte_to_ascii:
    push rbx
    movzx eax, dil
    mov bl, al
    shr al, 4
    and bl, 0x0F
    mov al, [hex_digits+rax]
    mov [rsi], al
    mov bl, [hex_digits+rbx]
    mov [rsi+1], bl
    pop rbx
    ret

; -----------------------------------------------------------------------------
; print_hex64
;   rdi = unsigned 64-bit value
;   output: "0x" + 16 uppercase hex digits (fixed width, no newline)
; -----------------------------------------------------------------------------
print_hex64:
    push rbx
    lea rbx, [hexbuf]
    mov byte [rbx], '0'
    mov byte [rbx+1], 'x'
    mov rcx, 16
    lea rsi, [rbx+2+15]     ; last digit position
    mov rax, rdi
.loop:
    mov rdx, rax
    and rdx, 0x0F
    mov dl, [hex_digits+rdx]
    mov [rsi], dl
    dec rsi
    shr rax, 4
    dec rcx
    jnz .loop
    mov rdi, STDOUT
    lea rsi, [hexbuf]
    mov rdx, 18
    call write_buf
    pop rbx
    ret

; -----------------------------------------------------------------------------
; print_bin64
;   rdi = unsigned 64-bit value
;   output: "0b" + 64 bits (fixed width, no newline)
; -----------------------------------------------------------------------------
print_bin64:
    push rbx
    lea rbx, [binbuf]
    mov byte [rbx], '0'
    mov byte [rbx+1], 'b'
    mov rcx, 64
    lea rsi, [rbx+2]
    mov rax, rdi
    mov r8, 1
    shl r8, 63
.loopb:
    test rax, r8
    jz .z
    mov byte [rsi], '1'
    jmp .c
.z:
    mov byte [rsi], '0'
.c:
    inc rsi
    shr r8, 1
    dec rcx
    jnz .loopb
    mov rdi, STDOUT
    lea rsi, [binbuf]
    mov rdx, 66
    call write_buf
    pop rbx
    ret

; -----------------------------------------------------------------------------
; utoa_base
;   rdi = unsigned value
;   edx = base (2..16)
;   rsi = destination buffer
;   returns rax = length (bytes written), no NUL terminator
;
; Notes:
; - Uses repeated division (value / base) extracting remainders.
; - Emits uppercase digits for 10..15 (A..F).
; -----------------------------------------------------------------------------
utoa_base:
    push rbx
    push r12
    push r13

    mov r12d, edx          ; base
    mov r13, rsi           ; save destination pointer

    lea rbx, [tmp_digits+79]
    mov byte [rbx], 0

    mov rax, rdi
    cmp rax, 0
    jne .repeat
    dec rbx
    mov byte [rbx], '0'
    jmp .emit

.repeat:
    xor edx, edx
    mov ecx, r12d
    div rcx                ; rax=quotient, rdx=remainder
    dec rbx
    mov dl, [hex_digits+rdx]
    mov [rbx], dl
    test rax, rax
    jnz .repeat

.emit:
    lea rax, [tmp_digits+79]
    sub rax, rbx           ; length

    mov rcx, rax
    mov rsi, rbx           ; source
    mov rdi, r13           ; dest
    rep movsb

    pop r13
    pop r12
    pop rbx
    ret

; -----------------------------------------------------------------------------
; print_dec_u64
;   rdi = unsigned 64-bit value
;   output: minimal decimal digits (no newline)
; -----------------------------------------------------------------------------
print_dec_u64:
    push rbx
    lea rbx, [tmp_digits]
    mov rsi, rbx
    mov edx, 10
    call utoa_base

    mov rdx, rax
    mov rdi, STDOUT
    mov rsi, rbx
    call write_buf

    pop rbx
    ret

%endif
