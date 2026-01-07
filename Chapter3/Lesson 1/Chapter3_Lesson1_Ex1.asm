; Chapter3_Lesson1_Ex1.asm
; Reusable include-style helpers for this lesson (NASM, Linux x86-64).
; You can include this file from other examples:
;   %include "Chapter3_Lesson1_Ex1.asm"
;
; Notes:
; - All helper routines are "leaf-friendly" and keep the calling contract simple:
;   * Caller assumes RAX, RCX, RDX, RSI, RDI, R8-R11 may be clobbered.
;   * RBX is preserved where used.

%ifndef CH3_L1_COMMON_INC
%define CH3_L1_COMMON_INC 1

; ----------------------------
; Linux x86-64 syscall numbers
; ----------------------------
%define SYS_read    0
%define SYS_write   1
%define SYS_exit   60

%define FD_STDIN    0
%define FD_STDOUT   1
%define FD_STDERR   2

; ----------------------------
; Syscall convenience macros
; ----------------------------
%macro sys_write 3
    ; sys_write(fd, buf, len)
    mov rax, SYS_write
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro sys_exit 1
    mov rax, SYS_exit
    mov rdi, %1
    syscall
%endmacro

; ----------------------------
; strlen_z: length of 0-terminated string
; Input : RDI = pointer
; Output: RAX = length (bytes before 0)
; ----------------------------
strlen_z:
    xor rax, rax
.len_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    ret

; ----------------------------
; write_z: write 0-terminated string to STDOUT
; Input : RDI = pointer
; Clobbers: RAX,RDI,RSI,RDX
; ----------------------------
write_z:
    push rdi
    call strlen_z
    pop rdi
    sys_write FD_STDOUT, rdi, rax
    ret

; ----------------------------
; hex64_to_ascii: convert 64-bit value to 16 ASCII hex chars (lowercase)
; Input : RAX = value
;         RDI = buffer (must have at least 16 bytes)
; Output: buffer[0..15] filled with hex digits
; Preserves: RBX
; ----------------------------
hex64_to_ascii:
    push rbx
    mov rbx, rax
    mov rcx, 16
.hex_loop:
    mov rax, rbx
    and rax, 0xF
    cmp al, 9
    jbe .digit
    add al, 'a' - 10
    jmp .store
.digit:
    add al, '0'
.store:
    mov [rdi + rcx - 1], al
    shr rbx, 4
    dec rcx
    jnz .hex_loop
    pop rbx
    ret

; ----------------------------
; write_hex64_ln: print 64-bit value in RAX as hex + newline
; Input : RAX = value
; Clobbers: RAX,RDI,RSI,RDX,RCX,R8-R11
; ----------------------------
write_hex64_ln:
    sub rsp, 32
    lea rdi, [rsp]
    call hex64_to_ascii
    mov byte [rsp + 16], 10
    sys_write FD_STDOUT, rsp, 17
    add rsp, 32
    ret

; ----------------------------
; write_str_and_hex64:
;   write a label string, then a 64-bit hex value, then newline
; Input:
;   RDI = pointer to 0-terminated label string
;   RAX = value
; ----------------------------
write_str_and_hex64:
    push rax
    call write_z
    pop rax
    call write_hex64_ln
    ret

%endif
