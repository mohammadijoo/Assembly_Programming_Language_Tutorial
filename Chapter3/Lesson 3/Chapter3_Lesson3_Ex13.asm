; Chapter 3 - Lesson 3 (Ex13) - Exercise 5 Solution
; Very hard: Build and validate a self-describing data blob using DB/DW/DD/DQ.
;
; Blob format (all little-endian):
;   dw magic = 0xC3A3
;   dw count = N
;   dd off_table = offset from blob base to table of N dword offsets
;   dd total_size = total bytes of blob
;   (padding bytes may follow, but must be accounted in total_size)
;   table: N dword offsets (each offset points to a NUL-terminated string)
;   strings: NUL-terminated
;
; The program checks:
;   1) magic matches
;   2) total_size matches (end - base)
;   3) each string offset is within total_size and points to a NUL-terminated string
; Then prints "OK\n" or "BAD\n".
;
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o
;   ./ex13

default rel
global _start

section .data
ok_msg  db "OK", 10
ok_len  equ $-ok_msg
bad_msg db "BAD", 10
bad_len equ $-bad_msg

blob:
    dw 0xC3A3              ; magic
    dw 3                   ; count
    dd off_table - blob    ; offset to table
    dd blob_end - blob     ; total_size

off_table:
    dd s1 - blob
    dd s2 - blob
    dd s3 - blob

s1 db "alpha", 0
s2 db "beta", 0
s3 db "gamma", 0
blob_end:

section .text
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_ok:
    mov rsi, ok_msg
    mov rdx, ok_len
    call write_stdout
    ret

print_bad:
    mov rsi, bad_msg
    mov rdx, bad_len
    call write_stdout
    ret

; is_nul_terminated(rdi=ptr, rsi=base, rdx=total_size) -> ZF=1 if ok
; Ensures ptr in [base, base+total_size), then scans until NUL without leaving range.
is_nul_terminated:
    ; range check ptr
    mov rax, rdi
    sub rax, rsi
    ; if rax >= total_size => fail
    cmp rax, rdx
    jae .fail

.scan:
    ; recompute remaining: (ptr - base) < total_size
    mov rcx, rdi
    sub rcx, rsi
    cmp rcx, rdx
    jae .fail
    cmp byte [rdi], 0
    je .ok
    inc rdi
    jmp .scan

.ok:
    xor eax, eax
    test eax, eax          ; set ZF=1
    ret
.fail:
    mov eax, 1
    test eax, eax          ; set ZF=0
    ret

_start:
    lea rbx, [blob]

    ; 1) magic
    movzx eax, word [rbx]
    cmp ax, 0xC3A3
    jne .bad

    ; 2) total_size matches computed size
    mov eax, dword [rbx + 8]        ; total_size
    mov ecx, blob_end - blob
    cmp eax, ecx
    jne .bad

    ; load count and off_table
    movzx ecx, word [rbx + 2]       ; count
    mov edx, dword [rbx + 4]        ; off_table
    mov esi, dword [rbx + 8]        ; total_size
    movzx rsi, esi                  ; rsi = total_size (64-bit)
    lea rdi, [rbx + rdx]            ; table ptr

    ; validate each offset and nul termination
    xor eax, eax
.loop:
    test ecx, ecx
    je .ok_all
    mov edx, dword [rdi]            ; offset
    lea r8, [rbx + rdx]             ; string ptr
    mov r9, rbx                     ; base
    mov r10, rsi                    ; total_size
    mov rdi, r8
    mov rsi, r9
    mov rdx, r10
    call is_nul_terminated
    jnz .bad

    add rdi, 4                      ; advance table pointer (dword offsets)
    dec ecx
    jmp .loop

.ok_all:
    call print_ok
    jmp .exit

.bad:
    call print_bad

.exit:
    mov eax, 60
    xor edi, edi
    syscall
