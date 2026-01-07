; Chapter3_Lesson10_Ex2.asm
; Bitfield insertion: clear field then OR in shifted value.
; Also demonstrates a simple range check for the inserted value.
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex2.asm && ld -o ex2 Chapter3_Lesson10_Ex2.o
; Run:      ./ex2

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_before: db "before = ",0
msg_after:  db "after  = ",0
msg_bad:    db "insert value out of range (masked)",10,0

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
    ; Start with a packed header template (same layout as Ex1):
    ; [31:24]=flags | [23:12]=length | [11:4]=type | [3:0]=version
    mov eax, 0xA5C3E21B
    mov ebx, eax            ; keep original for "before"
    lea rsi, [rel msg_before]
    call print_cstr
    mov edi, rbx
    call print_hex64

    ; Insert a new length field (12 bits at bit 12).
    ; New value is intentionally too large to show range checking/masking.
    mov esi, 0x2345         ; candidate length (0x2345 > 0xFFF)

    ; Range check: if (value > 0xFFF) warn.
    cmp esi, 0xFFF
    jbe .ok
    lea rsi, [rel msg_bad]
    call print_cstr
.ok:
    ; Mask the value down to 12 bits (defensive even if check passed)
    and esi, 0xFFF

    ; Build mask for the field in EDX: ((1<<12)-1) << 12 = 0x00FFF000
    mov edx, 0x00FFF000

    ; Clear the field in EAX
    not edx
    and eax, edx

    ; Insert masked value
    shl esi, 12
    or eax, esi

    ; Print result
    lea rsi, [rel msg_after]
    call print_cstr
    mov edi, rax
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
