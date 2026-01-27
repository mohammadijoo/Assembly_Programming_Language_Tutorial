; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define ROWS 3
%define COLS 6

section .data
mat dd  10, 11, 12, 13, 14, 15,
        21, 22,  5,  6, -7,  8,
        31, 32, 33,  0,  1,  2

msg1 db "First negative at (i,j) = (", 0
msg2 db "), value = ", 0
msgNF db "No negative values found", 0

section .text
global _start

_start:
    xor r13d, r13d            ; found = 0
    xor r14d, r14d            ; found_i
    xor r15d, r15d            ; found_j
    xor r12d, r12d            ; found_value (sign-extended)

    xor edi, edi              ; i = 0
.row:
    xor esi, esi              ; j = 0
.col:
    ; load mat[i][j] as signed dword
    mov eax, edi
    imul eax, COLS
    add eax, esi
    movsxd rax, dword [mat + rax*4]

    test eax, eax
    js .found

    inc esi
    cmp esi, COLS
    jl .col

    inc edi
    cmp edi, ROWS
    jl .row

    jmp .not_found

.found:
    mov r13d, 1
    mov r14d, edi
    mov r15d, esi
    mov r12, rax

.not_found:
    cmp r13d, 0
    je .print_nf

    ; Print: First negative at (i,j) = (i j), value = v
    lea rsi, [msg1]
    call print_cstr
    movzx rax, r14d
    call print_u64
    mov bl, ','
    call print_char_bl
    mov bl, ' '
    call print_char_bl
    movzx rax, r15d
    call print_u64

    lea rsi, [msg2]
    call print_cstr
    mov rax, r12
    call print_s64
    call print_newline
    xor edi, edi
    jmp exit

.print_nf:
    lea rsi, [msgNF]
    call print_cstr
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
