; file: checksum.asm
global xor_checksum
section .text
; uint8_t xor_checksum(uint8_t* p, uint64_t n)
; p=rdi, n=rsi, return in al
xor_checksum:
    xor eax, eax
.loop:
    test rsi, rsi
    jz .done
    xor al, byte [rdi]
    inc rdi
    dec rsi
    jmp .loop
.done:
    ret
