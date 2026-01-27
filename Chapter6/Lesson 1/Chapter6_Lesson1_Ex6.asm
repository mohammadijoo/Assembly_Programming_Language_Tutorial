; Chapter6_Lesson1_Ex6.asm
; Using a reusable "procedure macro header" via %include.
; We implement mem_zero(dst, len) using REP STOSB.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex6.asm -o ex6.o
;   ld ex6.o -o ex6
; Run:
;   ./ex6  (prints "done\n")

BITS 64
DEFAULT REL

%include "Chapter6_Lesson1_Ex5.asm"

GLOBAL _start

SECTION .data
msg:    db "done", 10
msglen: equ $-msg

SECTION .bss
buf:    resb 64

SECTION .text

; void mem_zero(uint8_t* dst, uint64_t len)
; SysV args: RDI=dst, RSI=len
PROC_BEGIN mem_zero, 0
    ; REP string ops use RCX as count, RDI as destination
    xor eax, eax              ; AL=0 byte
    mov rcx, rsi
    cld                       ; forward direction
    rep stosb
PROC_END

_start:
    ; Fill the buffer with nonzero bytes first so the zeroing is meaningful.
    lea rdi, [rel buf]
    mov rcx, 64
    mov al, 0x41              ; 'A'
.fill:
    mov [rdi], al
    inc rdi
    loop .fill

    ; Now zero it via our procedure
    lea rdi, [rel buf]
    mov rsi, 64
    call mem_zero

    ; Print a message
    mov eax, 1                ; __NR_write
    mov edi, 1                ; fd=stdout
    lea rsi, [rel msg]
    mov edx, msglen
    syscall

    mov eax, 60
    xor edi, edi
    syscall
