; Chapter7_Lesson10_Ex4.asm
; Topic: Length-prefixed buffers and safe slicing (no unbounded scanning)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
; Layout: [u32 length][bytes...]
lp_str:
    dd lp_str_end - (lp_str + 4)
    db "Length-prefixed output (no scan)."
lp_str_end:

; Slice request: offset + slice_len must be within the declared length
slice_off  dq 7
slice_len  dq 12

msg_bad    db "Rejected slice request.", 10
msg_bad_len equ $-msg_bad

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

_start:
    ; Print whole length-prefixed string
    mov eax, dword [lp_str]        ; len32
    mov edx, eax
    lea rsi, [lp_str + 4]
    call write_stdout
    ; newline
    mov rax, SYS_write
    mov rdi, 1
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

    ; Now print a bounded slice
    movzx rcx, dword [lp_str]      ; total_len
    mov r8, [slice_off]
    mov r9, [slice_len]

    ; Check offset <= total_len
    cmp r8, rcx
    ja .bad

    ; Check offset + slice_len <= total_len with carry detection
    mov rax, r8
    add rax, r9
    jc .bad
    cmp rax, rcx
    ja .bad

    ; write(lp_str+4+offset, slice_len)
    lea rsi, [lp_str + 4]
    add rsi, r8
    mov rdx, r9
    call write_stdout
    ; newline
    mov rax, SYS_write
    mov rdi, 1
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

    xor edi, edi
    jmp exit_

.bad:
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout
    mov edi, 1
    jmp exit_

section .data
nl db 10
