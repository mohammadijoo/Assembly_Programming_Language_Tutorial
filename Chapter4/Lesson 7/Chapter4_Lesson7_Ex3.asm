BITS 64
default rel
global _start

section .text
_start:
    ; Structured IF/ELSE using fall-through and inverted conditions.
    ; Goal: compute y = (x==0) ? 1 : (x+1), then return y in exit code (y & 0xFF).

    mov eax, 0            ; x (try changing to non-zero)
    test eax, eax
    jz .x_is_zero         ; taken when x==0

    ; ELSE: y = x + 1
    add eax, 1
    jmp .done

.x_is_zero:
    mov eax, 1            ; THEN: y = 1

.done:
    ; exit(y)
    mov edi, eax
    mov eax, 60
    syscall
