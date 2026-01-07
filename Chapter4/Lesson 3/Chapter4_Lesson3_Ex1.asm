; Chapter4_Lesson3_Ex1.asm
; Topic: Bit masks + fixed-position field extraction (Linux x86-64, NASM)
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex1.asm -o Chapter4_Lesson3_Ex1.o
;   ld -o Chapter4_Lesson3_Ex1 Chapter4_Lesson3_Ex1.o
; Run:
;   ./Chapter4_Lesson3_Ex1

BITS 64
default rel
global _start

section .data
msg_title    db "Bit-mask extraction demo", 10, 0
msg_a        db "A = ", 0
msg_lo12     db "low12(A) = ", 0
msg_mid8     db "bits[20..27](A) = ", 0
msg_hi16     db "high16(A) = ", 0
nl           db 10, 0

; Example 64-bit word
A           dq 0xF123456789ABCDEF

section .bss
hexbuf      resb 18          ; "0x" + 16 hex digits (no newline)

section .text

_start:
    ; Print title
    lea rdi, [msg_title]
    call print_cstr

    ; Load A
    mov rax, [A]

    lea rdi, [msg_a]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; Extract low 12 bits: A & ((1<<12)-1) = A & 0xFFF
    lea rdi, [msg_lo12]
    call print_cstr
    mov rbx, rax
    and rbx, 0xFFF
    mov rdi, rbx
    call print_hex64_nl

    ; Extract bits 20..27 (8 bits): (A >> 20) & 0xFF
    lea rdi, [msg_mid8]
    call print_cstr
    mov rbx, rax
    shr rbx, 20
    and rbx, 0xFF
    mov rdi, rbx
    call print_hex64_nl

    ; Extract high 16 bits: (A >> 48) & 0xFFFF
    lea rdi, [msg_hi16]
    call print_cstr
    mov rbx, rax
    shr rbx, 48
    and rbx, 0xFFFF
    mov rdi, rbx
    call print_hex64_nl

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

; -----------------------
; I/O helpers (sys_write)
; -----------------------

; print_cstr(rdi=ptr to zero-terminated string)
print_cstr:
    push rdi
    call cstr_len          ; rax = length
    pop rsi                ; rsi = ptr
    mov rdx, rax           ; count
    mov edi, 1             ; fd = stdout
    mov eax, 1             ; sys_write
    syscall
    ret

; cstr_len(rdi=ptr) -> rax=len (excluding terminator)
cstr_len:
    xor eax, eax
.len_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    ret

; print_hex64_nl(rdi=value)
print_hex64_nl:
    ; build "0x" + 16 hex digits into hexbuf, then write + newline
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rsi, [hexbuf]
    mov byte [rsi + 0], '0'
    mov byte [rsi + 1], 'x'

    mov rax, rdi
    mov rcx, 16
    lea rbx, [rsi + 2 + 15]   ; last hex digit position

.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    cmp dl, 9
    jbe .digit
    add dl, 7
.digit:
    add dl, '0'
    mov [rbx], dl
    shr rax, 4
    dec rbx
    loop .hex_loop

    ; write buffer (18 bytes)
    mov edi, 1
    lea rsi, [hexbuf]
    mov edx, 18
    mov eax, 1
    syscall

    ; write newline
    mov edi, 1
    lea rsi, [nl]
    mov edx, 1
    mov eax, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
