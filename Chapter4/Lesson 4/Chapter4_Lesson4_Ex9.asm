; Chapter4_Lesson4_Ex9.asm
; Exercise (Very Hard): 32-bit bitfield insert.
; Inputs:
;   EAX = x
;   EBX = field
;   ECX = start (0..31)
;   EDX = len (1..32)
; Output:
;   EAX = x with field inserted (low len bits of field) into [start .. start+len-1]
; Notes:
;   - This implementation handles len==32 by returning field (container fully overwritten).
;   - For simplicity, it assumes inputs are "sane" (start+len <= 32 when len != 32).
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg0 db "x (input)        = 0x",0
msg1 db "field (raw)      = 0x",0
msg2 db "start            = 0x",0
msg3 db "len              = 0x",0
msg4 db "x (after insert) = 0x",0

section .bss
buf times 18 db 0

section .text

print_cstr:
    push rax
    push rdi
    push rdx
    mov rdi, rsi
.len:
    cmp byte [rdi], 0
    je .go
    inc rdi
    jmp .len
.go:
    mov rdx, rdi
    sub rdx, rsi
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    pop rdx
    pop rdi
    pop rax
    ret

print_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    lea r8,  [rel hex_tbl]
    lea rdx, [rel buf]
    mov rcx, 16
.loop:
    rol rax, 4
    mov bl, al
    and bl, 0x0F
    mov bl, [r8 + rbx]
    mov [rdx], bl
    inc rdx
    loop .loop
    mov byte [rdx], 10
    mov rax, SYS_write
    mov rdi, STDOUT
    lea rsi, [rel buf]
    mov rdx, 17
    syscall
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

print_hex32:
    movzx rax, eax
    call print_hex64
    ret

; insert_field32:
;   EAX = x, EBX = field, ECX = start, EDX = len
; returns:
;   EAX = new x
insert_field32:
    push r8
    push r9
    push r10
    mov r8d, eax      ; x
    mov r9d, ebx      ; field
    mov r10d, ecx     ; start
    and r10d, 31

    cmp edx, 32
    jne .len_not_32
    mov eax, r9d
    jmp .done

.len_not_32:
    ; lowmask = (1<<len)-1  in EAX
    mov eax, 1
    mov ecx, edx
    and ecx, 31
    mov cl, cl
    shl eax, cl
    dec eax            ; lowmask

    ; mask = lowmask << start  in EBX
    mov ebx, eax
    mov ecx, r10d
    mov cl, cl
    shl ebx, cl

    ; field_aligned = (field & lowmask) << start  in EDX
    and r9d, eax
    mov edx, r9d
    mov ecx, r10d
    mov cl, cl
    shl edx, cl

    ; clear destination bits in x, then OR
    not ebx
    and r8d, ebx
    or  r8d, edx
    mov eax, r8d

.done:
    pop r10
    pop r9
    pop r8
    ret

_start:
    mov eax, 0xDEADBEEF
    mov ebx, 0x0000003A
    mov ecx, 9         ; start
    mov edx, 6         ; len

    lea rsi, [rel msg0]
    call print_cstr
    mov eax, 0xDEADBEEF
    call print_hex32

    lea rsi, [rel msg1]
    call print_cstr
    mov eax, 0x0000003A
    call print_hex32

    lea rsi, [rel msg2]
    call print_cstr
    mov eax, ecx
    call print_hex32

    lea rsi, [rel msg3]
    call print_cstr
    mov eax, edx
    call print_hex32

    mov eax, 0xDEADBEEF
    mov ebx, 0x0000003A
    mov ecx, 9
    mov edx, 6
    call insert_field32

    lea rsi, [rel msg4]
    call print_cstr
    call print_hex32

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
