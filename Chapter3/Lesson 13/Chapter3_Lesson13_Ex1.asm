; Chapter 3 - Lesson 13 (Include-style): Linux x86-64 minimal I/O helpers
; File: Chapter3_Lesson13_Ex1.asm
; Use: %include "Chapter3_Lesson13_Ex1.asm" from other examples in this lesson.
; Notes:
;   - This is intentionally "header-like" (no _start).
;   - All routines use Linux syscalls (no libc).
;   - Calling convention (informal):
;       * print_cstr:   rdi = pointer to 0-terminated string
;       * print_nl:     (no args)
;       * print_hex32:  edi = 32-bit value (prints 0xXXXXXXXX)
;       * print_hex64:  rdi = 64-bit value (prints 0xXXXXXXXXXXXXXXXX)
;       * print_u64:    rdi = unsigned 64-bit
;       * print_i64:    rdi = signed 64-bit
;   - Clobbers: rax, rcx, rdx, rsi, rdi, r8-r11 (syscall clobbers r11, rcx)

%ifndef CH3_L13_IO64_INCLUDED
%define CH3_L13_IO64_INCLUDED 1

%define SYS_write 1
%define SYS_exit  60
%define FD_STDOUT 1

section .rodata
hex_digits: db "0123456789ABCDEF"
nl_char:    db 10
minus_char: db "-"

section .bss
hexbuf64:   resb 18     ; "0x" + 16 hex digits
hexbuf32:   resb 10     ; "0x" + 8  hex digits
decbuf:     resb 32     ; enough for uint64 decimal

section .text

; write_buf(rsi=buf, rdx=len)
write_buf:
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
    ret

; print_cstr(rdi=ptr_to_zero_terminated_string)
; Uses REPNE SCASB to find the terminating 0 byte.
print_cstr:
    push rdi                ; save start pointer
    xor eax, eax            ; AL=0 for SCASB
    mov rcx, -1
    repne scasb             ; scan for 0
    not rcx                 ; rcx = bytes scanned including 0
    dec rcx                 ; rcx = length excluding 0
    pop rsi                 ; rsi = original pointer
    mov rdx, rcx
    jmp write_buf

print_nl:
    lea rsi, [rel nl_char]
    mov edx, 1
    jmp write_buf

; print_hex64(rdi=value)
print_hex64:
    push rbx
    mov rax, rdi

    lea rbx, [rel hexbuf64]
    mov byte [rbx+0], "0"
    mov byte [rbx+1], "x"

    lea rsi, [rbx+17]       ; last digit position
    mov ecx, 16
.hex64_loop:
    mov rdx, rax
    and edx, 0xF
    mov dl, [rel hex_digits + rdx]
    mov [rsi], dl
    shr rax, 4
    dec rsi
    loop .hex64_loop

    lea rsi, [rel hexbuf64]
    mov edx, 18
    pop rbx
    jmp write_buf

; print_hex32(edi=value)
print_hex32:
    push rbx
    mov eax, edi

    lea rbx, [rel hexbuf32]
    mov byte [rbx+0], "0"
    mov byte [rbx+1], "x"

    lea rsi, [rbx+9]        ; last digit position
    mov ecx, 8
.hex32_loop:
    mov edx, eax
    and edx, 0xF
    mov dl, [rel hex_digits + rdx]
    mov [rsi], dl
    shr eax, 4
    dec rsi
    loop .hex32_loop

    lea rsi, [rel hexbuf32]
    mov edx, 10
    pop rbx
    jmp write_buf

; print_u64(rdi=value)
print_u64:
    push rbx
    mov rax, rdi
    mov ebx, 10

    lea rsi, [rel decbuf + 31]  ; fill backwards from end
    xor ecx, ecx                ; digit count

    test rax, rax
    jnz .u64_loop

    ; value == 0
    dec rsi
    mov byte [rsi], "0"
    mov edx, 1
    pop rbx
    jmp write_buf

.u64_loop:
    xor edx, edx
    div rbx                 ; rax = rax/10, rdx = remainder
    add dl, "0"
    dec rsi
    mov [rsi], dl
    inc ecx
    test rax, rax
    jnz .u64_loop

    mov edx, ecx
    pop rbx
    jmp write_buf

; print_i64(rdi=value)
print_i64:
    test rdi, rdi
    jns .pos

    ; print '-'
    push rdi
    lea rsi, [rel minus_char]
    mov edx, 1
    call write_buf
    pop rdi

    neg rdi
    jo .int64_min            ; handle -2^63 case
    jmp print_u64

.int64_min:
    mov rdi, 9223372036854775808
    jmp print_u64

.pos:
    jmp print_u64

%endif
