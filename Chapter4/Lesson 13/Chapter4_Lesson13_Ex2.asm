; Chapter4_Lesson13_Ex2.asm
; Using NASM's ALIGN directive to align a hot loop boundary and padding with 0x90.
; Note: NASM's ALIGN fill defaults to 0x00 unless specified. We explicitly fill with 0x90.

BITS 64
GLOBAL _start

SECTION .text
_start:
    ; Do a little work before the loop (to make alignment not trivially at section start).
    mov ecx, 7
    add ecx, 5

    ; Align the next label to 32 bytes and fill with 0x90.
    align 32, db 0x90

hot_loop:
    ; A trivial dependency chain to keep the loop "real".
    add ecx, 1
    sub ecx, 1
    dec r8d
    jnz hot_loop

    ; Initialize r8d after the first pass so this example is safe to run.
    ; If r8d was 0 on entry, DEC makes it 0xFFFFFFFF and the loop runs "forever".
    ; For demonstration, re-enter with a finite count.
    mov r8d, 20000000
    jmp hot_loop

    ; Unreachable; included as a template for educational clarity.
    mov eax, 60
    xor edi, edi
    syscall
