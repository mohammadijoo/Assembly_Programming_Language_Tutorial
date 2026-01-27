bits 64
default rel

global _start
section .text

; Ex7: Code layout knobs that influence displacement:
; - ALIGN can insert NOP padding.
; - TIMES can insert explicit padding.
; - Placing cold code in a separate section encourages distance.
; Use this to keep hot-path branches short and predictable.

_start:
    ; Hot path: keep tiny, pack labels close.
    cmp edi, 0
    jne short .hot_done

    ; Cold path entry (still in .text, but we'll jump out to a cold section).
    jmp near cold_path

.hot_done:
    ; Exit(0)
    xor edi, edi
    mov eax, 60
    syscall

; Alignment padding (changes offsets; can push short branches out of range if abused).
align 16

section .text.cold

cold_path:
    ; A deliberately large cold block
    times 512 nop
    mov edi, 2
    mov eax, 60
    syscall
