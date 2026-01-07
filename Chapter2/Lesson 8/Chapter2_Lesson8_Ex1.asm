;
; Chapter 2 - Lesson 8 - Example 1
; Support routines for observing flags in NASM x86-64 on Linux.
;
; Intended usage:
;   %include "Chapter2_Lesson8_Ex1.asm"
; inside other examples in this lesson.
;
; Assemble & link (example for a file that includes this):
;   nasm -felf64 Chapter2_Lesson8_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;
; Notes:
; - This helper uses Linux syscalls (write, exit).
; - It prints RFLAGS (captured via PUSHFQ/POPFQ) and selected flags.

%ifndef CH2_L8_SUPPORT_ASM
%define CH2_L8_SUPPORT_ASM 1

BITS 64
default rel

%macro SYS_WRITE 2
    ; SYS_WRITE ptr, len
    mov rax, 1
    mov rdi, 1
    lea rsi, [%1]
    mov rdx, %2
    syscall
%endmacro

%macro SYS_EXIT 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro

section .rodata
hex_digits: db "0123456789ABCDEF"

msg_CF: db "CF=",0
msg_ZF: db " ZF=",0
msg_SF: db " SF=",0
msg_OF: db " OF=",0
msg_PF: db " PF=",0
msg_ENDL: db 10

section .bss
hexbuf:  resb 2+16+1         ; "0x" + 16 hex digits + '\n'
bitbuf:  resb 1

section .text

; ---------------------------------------------------------------------------
; print_str: write(stdout, rsi, rdx)
; Clobbers: rax, rdi
; ---------------------------------------------------------------------------
print_str:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

print_nl:
    lea rsi, [msg_ENDL]
    mov rdx, 1
    call print_str
    ret

; ---------------------------------------------------------------------------
; print_bit_al: prints '0' or '1' for AL in {0,1}
; Clobbers: rax, rdi, rsi, rdx
; ---------------------------------------------------------------------------
print_bit_al:
    add al, '0'
    mov [bitbuf], al
    lea rsi, [bitbuf]
    mov rdx, 1
    call print_str
    ret

; ---------------------------------------------------------------------------
; print_hex64_rax: prints RAX as 0x????????????????\n
; Preserves: rbx, rcx, r8, r9
; Clobbers: rax, rsi, rdx, rdi
; ---------------------------------------------------------------------------
print_hex64_rax:
    push rbx
    push rcx
    push r8
    push r9

    mov rbx, rax
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'

    lea rsi, [hexbuf+2]
    mov rcx, 16
    mov r9b, 60

.hex_loop:
    mov rax, rbx
    mov cl, r9b
    shr rax, cl
    and eax, 0xF
    mov al, [hex_digits + rax]
    mov [rsi], al
    inc rsi
    sub r9b, 4
    dec rcx
    jnz .hex_loop

    mov byte [hexbuf+18], 10
    lea rsi, [hexbuf]
    mov rdx, 19
    call print_str

    pop r9
    pop r8
    pop rcx
    pop rbx
    ret

; ---------------------------------------------------------------------------
; dump_flags_basic:
; Input: RAX = captured RFLAGS
; Prints: CF, ZF, SF, OF, PF as 0/1.
; Preserves: rbx
; ---------------------------------------------------------------------------
dump_flags_basic:
    push rbx
    mov rbx, rax

    ; CF bit 0
    lea rsi, [msg_CF]
    mov rdx, 3
    call print_str
    bt rbx, 0
    setc al
    call print_bit_al

    ; ZF bit 6
    lea rsi, [msg_ZF]
    mov rdx, 4
    call print_str
    bt rbx, 6
    setc al
    call print_bit_al

    ; SF bit 7
    lea rsi, [msg_SF]
    mov rdx, 4
    call print_str
    bt rbx, 7
    setc al
    call print_bit_al

    ; OF bit 11
    lea rsi, [msg_OF]
    mov rdx, 4
    call print_str
    bt rbx, 11
    setc al
    call print_bit_al

    ; PF bit 2
    lea rsi, [msg_PF]
    mov rdx, 4
    call print_str
    bt rbx, 2
    setc al
    call print_bit_al

    call print_nl
    pop rbx
    ret

%endif
