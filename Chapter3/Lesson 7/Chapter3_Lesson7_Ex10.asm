bits 64
default rel

global _start

; Chapter 3, Lesson 7, Exercise Solution 2
; Count Unicode code points in a UTF-8 string with validation.
;
; utf8_count(rdi=ptr, rsi=len) -> rax=count, rdx=status (0 ok, nonzero error),
;                               rcx=error_index (only if status != 0)
;
; Demo prints count as decimal for a valid string.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    ; "Hi € 😀\n"
    s:  db 'H','i',' ',0xE2,0x82,0xAC,' ',0xF0,0x9F,0x98,0x80,10
    s_len: equ $ - s

    prefix: db "Code points count = "
    prefix_len: equ $ - prefix

    nl: db 10

section .bss
    decbuf: resb 32

section .text

_start:
    lea rdi, [s]
    mov esi, s_len
    call utf8_count
    test edx, edx
    jnz .err

    ; print prefix
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [prefix]
    mov edx, prefix_len
    syscall

    ; print decimal rax (count)
    lea rdi, [decbuf]
    mov rsi, rax
    call u64_to_dec
    ; returns rax=ptr, rcx=len
    mov eax, SYS_write
    mov edi, STDOUT
    mov rsi, rax
    mov edx, ecx
    syscall

    ; newline
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [nl]
    mov edx, 1
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

.err:
    mov edi, 1
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; utf8_count
; IN:  RDI=ptr, ESI=len
; OUT: RAX=count
;      EDX=status (0 ok)
;      RCX=error_index (if status != 0)
; -------------------------------------------------------
utf8_count:
    xor r15d, r15d      ; count (64-bit, but small)
    xor edx, edx        ; status
    xor ecx, ecx        ; error_index

    mov r8, rdi         ; base
    mov r9d, esi        ; len
    xor r10d, r10d      ; i

.loop:
    cmp r10d, r9d
    jae .ok

    movzx ebx, byte [r8 + r10]
    cmp bl, 0x80
    jb  .one

    ; 2-byte lead: C2..DF
    cmp bl, 0xC2
    jb  .bad_lead
    cmp bl, 0xDF
    jbe .two

    ; 3-byte lead: E0..EF
    cmp bl, 0xE0
    jb  .bad_lead
    cmp bl, 0xEF
    jbe .three

    ; 4-byte lead: F0..F4
    cmp bl, 0xF0
    jb  .bad_lead
    cmp bl, 0xF4
    jbe .four

    jmp .bad_lead

.one:
    inc r10d
    inc r15
    jmp .loop

.two:
    lea r11d, [r10d + 1]
    cmp r11d, r9d
    jae .trunc

    movzx edi, byte [r8 + r10 + 1]
    call cont_ok
    test eax, eax
    jz .bad_cont

    add r10d, 2
    inc r15
    jmp .loop

.three:
    lea r11d, [r10d + 2]
    cmp r11d, r9d
    jae .trunc

    movzx edi, byte [r8 + r10 + 1]
    call cont_ok
    test eax, eax
    jz .bad_cont
    movzx edi, byte [r8 + r10 + 2]
    call cont_ok
    test eax, eax
    jz .bad_cont

    ; constraints for E0/ED
    movzx eax, byte [r8 + r10]     ; lead
    movzx edi, byte [r8 + r10 + 1] ; b1
    cmp al, 0xE0
    jne .chk_ed
    cmp dil, 0xA0
    jb  .overlong
.chk_ed:
    cmp al, 0xED
    jne .ok3
    cmp dil, 0x9F
    ja  .surrogate
.ok3:
    add r10d, 3
    inc r15
    jmp .loop

.four:
    lea r11d, [r10d + 3]
    cmp r11d, r9d
    jae .trunc

    movzx edi, byte [r8 + r10 + 1]
    call cont_ok
    test eax, eax
    jz .bad_cont
    movzx edi, byte [r8 + r10 + 2]
    call cont_ok
    test eax, eax
    jz .bad_cont
    movzx edi, byte [r8 + r10 + 3]
    call cont_ok
    test eax, eax
    jz .bad_cont

    movzx eax, byte [r8 + r10]     ; lead
    movzx edi, byte [r8 + r10 + 1] ; b1
    cmp al, 0xF0
    jne .chk_f4
    cmp dil, 0x90
    jb  .overlong
.chk_f4:
    cmp al, 0xF4
    jne .ok4
    cmp dil, 0x8F
    ja  .range
.ok4:
    add r10d, 4
    inc r15
    jmp .loop

.ok:
    mov rax, r15
    xor edx, edx
    ret

.trunc:
    xor rax, rax
    mov edx, 1
    mov ecx, r10d
    ret

.bad_lead:
    xor rax, rax
    mov edx, 2
    mov ecx, r10d
    ret

.bad_cont:
    xor rax, rax
    mov edx, 3
    mov ecx, r10d
    ret

.overlong:
    xor rax, rax
    mov edx, 4
    mov ecx, r10d
    ret

.surrogate:
    xor rax, rax
    mov edx, 5
    mov ecx, r10d
    ret

.range:
    xor rax, rax
    mov edx, 6
    mov ecx, r10d
    ret

cont_ok:
    mov eax, edi
    and eax, 0xC0
    cmp eax, 0x80
    sete al
    movzx eax, al
    ret

; -------------------------------------------------------
; u64_to_dec
; IN:  RDI=buffer (>= 32), RSI=value
; OUT: RAX=ptr to first digit, RCX=len
; -------------------------------------------------------
u64_to_dec:
    lea r8, [rdi + 31]
    mov byte [r8], 0
    xor ecx, ecx

    mov rax, rsi
    cmp rax, 0
    jne .loop
    mov byte [r8-1], '0'
    lea rax, [r8-1]
    mov ecx, 1
    ret

.loop:
    xor rdx, rdx
    mov r9, 10
    div r9                    ; rax /= 10, rdx = remainder

    add dl, '0'
    dec r8
    mov [r8], dl
    inc ecx

    test rax, rax
    jnz .loop

    mov rax, r8
    ret
