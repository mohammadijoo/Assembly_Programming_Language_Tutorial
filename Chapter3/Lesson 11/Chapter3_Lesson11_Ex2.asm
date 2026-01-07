; Chapter 3 - Lesson 11 - Example 2
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2
;
; Purpose:
;   Use NASM STRUC/ENDSTRUC plus ALIGN inside the STRUC to model "C-like" padding.
;   Print offsets and total sizes at runtime.

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg1 db "PERSON (aligned) layout",10,0
    msg2 db "  id offset     = ",0
    msg3 db "  age offset    = ",0
    msg4 db "  salary offset = ",0
    msg5 db "  total size    = ",0
    msg6 db 10,"PERSON_PACKED (no explicit alignment) layout",10,0
    msg7 db "  id offset     = ",0
    msg8 db "  age offset    = ",0
    msg9 db "  salary offset = ",0
    msg10 db "  total size    = ",0

hex_lut db "0123456789ABCDEF"

; -----------------------------------------
; STRUCT DEFINITIONS
; -----------------------------------------
struc PERSON
    .id     resd 1        ; 4 bytes
    .age    resb 1        ; 1 byte
    align 8               ; align next field to 8-byte boundary (common for qword)
    .salary resq 1        ; 8 bytes
endstruc

struc PERSON_PACKED
    .id     resd 1
    .age    resb 1
    .salary resq 1        ; immediately after age (likely misaligned)
endstruc

section .bss
    hexbuf resb 19

section .text
global _start

write_buf:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

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

print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'
    mov rbx, rax
    mov rcx, 16
    lea rdi, [hexbuf + 2 + 15]
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

; print "label" then hex(RAX)
print_labeled_hex:
    call print_z
    call print_hex64
    ret

_start:
    ; PERSON
    lea rsi, [msg1]
    call print_z

    lea rsi, [msg2]
    mov rax, PERSON.id
    call print_labeled_hex

    lea rsi, [msg3]
    mov rax, PERSON.age
    call print_labeled_hex

    lea rsi, [msg4]
    mov rax, PERSON.salary
    call print_labeled_hex

    lea rsi, [msg5]
    mov rax, PERSON_size
    call print_labeled_hex

    ; PERSON_PACKED
    lea rsi, [msg6]
    call print_z

    lea rsi, [msg7]
    mov rax, PERSON_PACKED.id
    call print_labeled_hex

    lea rsi, [msg8]
    mov rax, PERSON_PACKED.age
    call print_labeled_hex

    lea rsi, [msg9]
    mov rax, PERSON_PACKED.salary
    call print_labeled_hex

    lea rsi, [msg10]
    mov rax, PERSON_PACKED_size
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall
