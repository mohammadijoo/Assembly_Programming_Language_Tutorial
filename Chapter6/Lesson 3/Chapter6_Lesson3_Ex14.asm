; Chapter6_Lesson3_Ex14.asm
; Programming Exercise 5 (Hard): memcmp-like routine to emphasize pointer args
; and return conventions.
;
; Signature:
;   int64 memcmp_u8(const uint8 *a, const uint8 *b, uint64 n)
; Return: 0 if equal; negative if a<b; positive if a>b (first differing byte).
;
; SysV: a=RDI, b=RSI, n=RDX, return=RAX
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex14.asm -o ex14.o
;   ld -o ex14 ex14.o
; Run:
;   ./ex14 ; exit code = 1 (a[3]=0x40 > b[3]=0x30)

global _start

section .data
a db 0x10, 0x20, 0x30, 0x40
b db 0x10, 0x20, 0x30, 0x30

section .text

memcmp_u8:
    xor     eax, eax
    test    rdx, rdx
    jz      .done

.loop:
    movzx   ecx, byte [rdi]
    movzx   r8d, byte [rsi]
    cmp     ecx, r8d
    jne     .diff
    inc     rdi
    inc     rsi
    dec     rdx
    jnz     .loop
    xor     eax, eax
    ret

.diff:
    ; Return sign of (a[i] - b[i]) as a signed 64-bit.
    mov     eax, ecx
    sub     eax, r8d
    cdqe
    ret

.done:
    ret

_start:
    lea     rdi, [rel a]
    lea     rsi, [rel b]
    mov     edx, 4
    call    memcmp_u8

    ; Map negative to 255, positive to 1, zero to 0 for exit status demonstration.
    test    eax, eax
    jz      .exit0
    js      .exit_neg
    mov     edi, 1
    jmp     .exit
.exit_neg:
    mov     edi, 255
    jmp     .exit
.exit0:
    xor     edi, edi
.exit:
    mov     eax, 60
    syscall
