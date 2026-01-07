; Chapter 3 - Lesson 4 (Working with Constants)
; Example 16 (Exercise Solution): Base-N integer formatting chosen at assembly time

global _start
default rel

; Change BASE and rebuild to get a different code path.
BASE       equ 10          ; valid range: 2..16
USE_LOWER  equ 0           ; 0 = ABCDEF, 1 = abcdef

%if (BASE < 2) || (BASE > 16)
    %error "BASE must satisfy 2 <= BASE <= 16"
%endif

; Provide a printable BASE_STR for the banner (keeps the example self-contained)
%if BASE = 2
    %define BASE_STR "2"
%elif BASE = 3
    %define BASE_STR "3"
%elif BASE = 4
    %define BASE_STR "4"
%elif BASE = 5
    %define BASE_STR "5"
%elif BASE = 6
    %define BASE_STR "6"
%elif BASE = 7
    %define BASE_STR "7"
%elif BASE = 8
    %define BASE_STR "8"
%elif BASE = 9
    %define BASE_STR "9"
%elif BASE = 10
    %define BASE_STR "10"
%elif BASE = 11
    %define BASE_STR "11"
%elif BASE = 12
    %define BASE_STR "12"
%elif BASE = 13
    %define BASE_STR "13"
%elif BASE = 14
    %define BASE_STR "14"
%elif BASE = 15
    %define BASE_STR "15"
%elif BASE = 16
    %define BASE_STR "16"
%endif

section .data
; digit table is also selected at assembly time
%if USE_LOWER
digits db "0123456789abcdef"
%else
digits db "0123456789ABCDEF"
%endif

outbuf     times 64 db 0
hexdigits  db "0123456789ABCDEF"
hexbuf     db "0x0000000000000000", 10
hexbuf_len equ $ - hexbuf

hdr        db "itoa with BASE chosen at assembly time (BASE=", BASE_STR, ")", 10
hdr_len    equ $ - hdr

section .text
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

print_hex64:
    mov rbx, rax
    lea rdi, [hexbuf + 2 + 15]
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop
    lea rsi, [hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

; utoa_base:
;   RAX = unsigned value
;   prints value in BASE (2..16) + newline
; clobbers: RAX,RBX,RCX,RDX,RSI,RDI
utoa_base:
    lea rdi, [outbuf + 63]     ; write digits backwards
    mov byte [rdi], 10         ; newline sentinel
    dec rdi
    xor ecx, ecx               ; digit count

%if (BASE = 2) || (BASE = 4) || (BASE = 8) || (BASE = 16)
    ; power-of-two fast path: use shifts/masks
    %assign SHIFT 0
    %if BASE = 2
        %assign SHIFT 1
    %elif BASE = 4
        %assign SHIFT 2
    %elif BASE = 8
        %assign SHIFT 3
    %elif BASE = 16
        %assign SHIFT 4
    %endif
    %assign MASK (BASE - 1)

.pow2_loop:
    mov rbx, rax
    and ebx, MASK
    mov bl, [digits + rbx]
    mov [rdi], bl
    dec rdi
    inc ecx
    shr rax, SHIFT
    test rax, rax
    jnz .pow2_loop

%else
    ; general path: repeated division by constant BASE
    mov ebx, BASE
.div_loop:
    xor edx, edx
    div rbx                  ; quotient in RAX, remainder in RDX
    mov dl, [digits + rdx]
    mov [rdi], dl
    dec rdi
    inc ecx
    test rax, rax
    jnz .div_loop
%endif

    ; write the digit sequence plus newline
    inc rdi
    lea rsi, [rdi]
    lea edx, [ecx + 1]       ; digits + newline
    write_stdout
    ret

_start:
    lea rsi, [hdr]
    mov edx, hdr_len
    write_stdout

    ; Demonstrate two values
    mov rax, 123456789
    call utoa_base

    mov rax, 0xDEADBEEF
    call utoa_base

    ; For verification: also show the second value in hex unconditionally
    mov rax, 0xDEADBEEF
    call print_hex64

    xor edi, edi
    exit
