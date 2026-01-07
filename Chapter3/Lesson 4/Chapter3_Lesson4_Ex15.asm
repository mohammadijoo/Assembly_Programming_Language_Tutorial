; Chapter 3 - Lesson 4 (Working with Constants)
; Example 15 (Exercise Solution): Compile-time CRC32 table generation + runtime CRC32

global _start
default rel

POLY        equ 0xEDB88320       ; reflected CRC-32 polynomial
CRC_INIT    equ 0xFFFFFFFF

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "CRC32 (table generated at assembly time):", 10
hdr_len      equ $ - hdr

msg          db "Assembly constants are doing real work here.", 10
msg_len      equ $ - msg

; -----------------------------------------
; Generate CRC32 table at assembly time
; table[i] = crc(i) after 8 iterations
; -----------------------------------------
crc32_table:
%assign i 0
%rep 256
    %assign crc i
    %assign j 0
    %rep 8
        %if (crc & 1)
            %assign crc (crc >> 1) ^ POLY
        %else
            %assign crc (crc >> 1)
        %endif
        %assign j j+1
    %endrep
    dd crc
    %assign i i+1
%endrep

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

; crc32_compute:
;   RSI = buffer, RDX = length
;   returns EAX = CRC32
crc32_compute:
    push rbx
    mov eax, CRC_INIT
    xor ebx, ebx
.loop_bytes:
    test rdx, rdx
    jz .done
    mov bl, [rsi]
    ; idx = (crc ^ b) & 0xFF
    mov ecx, eax
    xor cl, bl
    and ecx, 0xFF
    ; crc = (crc >> 8) ^ table[idx]
    shr eax, 8
    xor eax, [crc32_table + rcx*4]
    inc rsi
    dec rdx
    jmp .loop_bytes
.done:
    not eax
    pop rbx
    ret

_start:
    lea rsi, [hdr]
    mov edx, hdr_len
    write_stdout

    lea rsi, [msg]
    mov edx, msg_len
    write_stdout

    lea rsi, [msg]
    mov edx, msg_len
    call crc32_compute

    movzx rax, eax
    call print_hex64

    xor edi, edi
    exit
