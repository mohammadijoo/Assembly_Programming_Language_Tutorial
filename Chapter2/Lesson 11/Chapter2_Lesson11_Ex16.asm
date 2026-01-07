; Solution-oriented example: "API surface" conventions using global.
; Even in small projects, explicitly list exported symbols.

BITS 64
global api_version
global api_add1

section .text
api_version:
    mov     eax, 1
    ret

api_add1:
    ; Input: edi = x, Output: eax = x + 1
    lea     eax, [rdi + 1]
    ret
