; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
section .data
hay    db "bananabanaba", 0
needle db "naba", 0
msg1   db "First occurrence index = ", 0

section .text
global _start

_start:
    ; Naive substring search:
    ; for i in [0..len(hay)-1]:
    ;   for j in [0..len(needle)-1]:
    ;     if hay[i+j] != needle[j] break
    ;   if needle[j]==0 => found at i

    xor edi, edi              ; i = 0
.outer:
    mov al, [hay + rdi]
    test al, al
    je .not_found             ; reached end => not found

    xor esi, esi              ; j = 0
.inner:
    mov al, [needle + rsi]
    test al, al
    je .found                 ; end of needle => match

    mov bl, [hay + rdi + rsi]
    test bl, bl
    je .not_found             ; hay ended before needle

    cmp bl, al
    jne .mismatch

    inc esi
    jmp .inner

.mismatch:
    inc edi
    jmp .outer

.found:
    lea rsi, [msg1]
    call print_cstr
    mov rax, rdi
    call print_u64
    call print_newline
    xor edi, edi
    jmp exit

.not_found:
    lea rsi, [msg1]
    call print_cstr
    mov rax, -1
    call print_s64
    call print_newline
    xor edi, edi
    jmp exit

; RSI = zero-terminated string
print_cstr:
    push rdx
    xor edx, edx
.len:
    cmp byte [rsi + rdx], 0
    je .emit
    inc edx
    jmp .len
.emit:
    call _write_stdout
    pop rdx
    ret

\
; ----------------------------
; Minimal I/O helpers (Linux)
; ----------------------------
%define SYS_write 1
%define SYS_exit  60

section .bss
numbuf  resb 32
chbuf   resb 1

section .text

; write(fd=1, buf=rsi, len=rdx)
_write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

; BL = character
print_char_bl:
    mov [chbuf], bl
    lea rsi, [chbuf]
    mov edx, 1
    jmp _write_stdout

print_newline:
    mov bl, 10
    jmp print_char_bl

print_space:
    mov bl, ' '
    jmp print_char_bl

; RAX = unsigned 64-bit integer
print_u64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rdi, [numbuf + 31]     ; one past last printable digit slot
    mov byte [rdi], 0

    mov rbx, 10
    cmp rax, 0
    jne .convert

    dec rdi
    mov byte [rdi], '0'
    jmp .emit

.convert:
    ; produce digits in reverse
.loop:
    xor edx, edx
    div rbx                   ; RAX = quotient, RDX = remainder
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jne .loop

.emit:
    lea rsi, [rdi]
    lea rdx, [numbuf + 31]
    sub rdx, rsi              ; len = end - start
    call _write_stdout

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; RAX = signed 64-bit integer
print_s64:
    test rax, rax
    jns .pos
    mov bl, '-'
    call print_char_bl
    neg rax
.pos:
    jmp print_u64

; Exit with status in EDI
exit:
    mov eax, SYS_exit
    syscall
