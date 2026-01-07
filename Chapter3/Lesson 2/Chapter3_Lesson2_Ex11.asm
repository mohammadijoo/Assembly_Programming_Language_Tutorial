; Chapter 3 - Lesson 2 (Programming Exercise 3 — Solution)
; Key-value lookup table (key: byte, value: dword). Linear search.
; Stores found flag/value into variables and prints the result in hex.

BITS 64
default rel

%include "Chapter3_Lesson2_Ex8.asm"

section .rodata
hex_digits  db "0123456789ABCDEF"

msg_found   db "FOUND value = 0x"
msg_found_len equ $ - msg_found

msg_not     db "NOTFOUND", 10
msg_not_len equ $ - msg_not

nl          db 10
nl_len      equ 1

section .data
; Layout: [key:1][value:4] repeated. Total entry size = 5 bytes.
table:
    db 'A'          ; key
    dd 0x13579BDF   ; value
    db 'C'
    dd 0xDEADBEEF
    db 'Z'
    dd 0x0000BEEF
    db 'm'
    dd 0x00C0FFEE
table_len   equ $ - table
entry_size  equ 5
entry_count equ table_len / entry_size

query_key   db 'C'          ; change this to test ('A','C','Z','m',...)

found_flag  db 0
found_val   dd 0

section .bss
hexbuf      resb 8          ; exactly 8 hex digits

section .text
global _start

; ------------------------------------------------------------
; to_hex8
;   edi = 32-bit value
;   rsi = destination buffer (8 bytes)
; Produces 8 ASCII hex digits, big-endian order (MS nibble first).
; clobbers: rax, rbx, rcx, rdx, r8
; ------------------------------------------------------------
to_hex8:
    mov     eax, edi
    mov     ecx, 8
    mov     rbx, 28         ; starting shift
.nibble:
    mov     edx, eax
    shr     edx, bl
    and     edx, 0xF
    movzx   r8d, byte [hex_digits + rdx]
    mov     byte [rsi], r8b
    inc     rsi
    sub     rbx, 4
    dec     ecx
    jne     .nibble
    ret

_start:
    xor     ebx, ebx        ; i=0
    mov     al, byte [query_key]

.search:
    cmp     ebx, entry_count
    jae     .not_found

    lea     rdx, [table + rbx*entry_size]
    cmp     al, byte [rdx]              ; key compare
    je      .found

    inc     ebx
    jmp     .search

.found:
    mov     byte [found_flag], 1
    mov     eax, dword [rdx + 1]        ; value right after key byte
    mov     dword [found_val], eax

    ; Print "FOUND value = 0x" then 8 hex digits + newline
    WRITE   msg_found, msg_found_len

    mov     edi, dword [found_val]
    lea     rsi, [hexbuf]
    call    to_hex8

    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [hexbuf]
    mov     edx, 8
    syscall

    WRITE   nl, nl_len
    EXIT    0

.not_found:
    mov     byte [found_flag], 0
    mov     dword [found_val], 0
    WRITE   msg_not, msg_not_len
    EXIT    0
