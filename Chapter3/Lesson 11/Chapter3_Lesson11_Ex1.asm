; Chapter 3 - Lesson 11 - Example 1
; Alignment, Padding, and Data Layout (Why Misalignment Can Hurt)
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson11_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1
;
; Purpose:
;   Show how NASM's ALIGN directive changes label addresses, and how to
;   compute alignment remainders at runtime (address mod 16, mod 64).

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msgA db "addr(varA)        = ",0
    len_msgA equ $-msgA

    msgB db "addr(varB)        = ",0
    len_msgB equ $-msgB

    msgC db "addr(varC)        = ",0
    len_msgC equ $-msgC

    msgD db "addr(varD)        = ",0
    len_msgD equ $-msgD

    msg16 db "  mod 16 remainder = ",0
    len_msg16 equ $-msg16

    msg64 db "  mod 64 remainder = ",0
    len_msg64 equ $-msg64

    nl db 10

    ; Intentional layout experiments
varA:   db 0x11               ; 1 byte

        align 8               ; next label aligned to 8 bytes
varB:   dq 0x2222222222222222

        db 0x33               ; create a misaligned "hole" again
        align 16              ; force 16-byte alignment
varC:   dq 0x4444444444444444
        dq 0x5555555555555555

        align 64              ; cache-line alignment (typical)
varD:   times 32 db 0x66

hex_lut db "0123456789ABCDEF"

section .bss
    hexbuf resb 19            ; "0x" + 16 hex digits + "\n"

section .text
global _start

; -----------------------------------------
; write(STDOUT, rsi, rdx)
; clobbers: rax, rdi
; -----------------------------------------
write_buf:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

; -----------------------------------------
; print a zero-terminated string at rsi
; clobbers: rax, rcx, rdx, rdi
; -----------------------------------------
print_z:
    xor ecx, ecx
.count:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .count
.done:
    mov rdx, rcx
    call write_buf
    ret

; -----------------------------------------
; print hex of RAX (64-bit) as 0x................\n
; clobbers: rbx, rcx, rdx, rdi, rsi, rax
; -----------------------------------------
print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'

    mov rbx, rax
    mov rcx, 16
    lea rdi, [hexbuf + 2 + 15]   ; last digit position

.hex_loop:
    mov rdx, rbx
    and rdx, 0xF
    mov dl, [hex_lut + rdx]
    mov [rdi], dl
    shr rbx, 4
    dec rdi
    dec rcx
    jnz .hex_loop

    mov byte [hexbuf + 18], 10

    lea rsi, [hexbuf]
    mov edx, 19
    call write_buf
    ret

; -----------------------------------------
; print "label: <hex>\n  mod 16 remainder: <hex>\n  mod 64 remainder: <hex>\n\n"
; input: rsi = pointer to msg (zero-terminated), rbx = address to report
; clobbers: rax, rcx, rdx, rdi, rsi
; -----------------------------------------
report_addr:
    ; print header
    call print_z
    mov rax, rbx
    call print_hex64

    ; mod 16
    lea rsi, [msg16]
    call print_z
    mov rax, rbx
    and rax, 15
    call print_hex64

    ; mod 64
    lea rsi, [msg64]
    call print_z
    mov rax, rbx
    and rax, 63
    call print_hex64

    ; blank line
    lea rsi, [nl]
    mov edx, 1
    call write_buf
    ret

_start:
    ; varA
    lea rsi, [msgA]
    lea rbx, [varA]
    call report_addr

    ; varB
    lea rsi, [msgB]
    lea rbx, [varB]
    call report_addr

    ; varC
    lea rsi, [msgC]
    lea rbx, [varC]
    call report_addr

    ; varD
    lea rsi, [msgD]
    lea rbx, [varD]
    call report_addr

    mov eax, SYS_exit
    xor edi, edi
    syscall
