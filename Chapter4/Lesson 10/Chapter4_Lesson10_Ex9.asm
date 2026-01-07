bits 64
default rel

; Pitfalls:
; 1) LEA does not dereference memory: it computes an address only.
; 2) In 64-bit mode, writing a 32-bit register (e.g., EAX) zero-extends to RAX.

global _start

section .data
arr dq 0x1122334455667788, 0x99AABBCCDDEEFF00

section .text
_start:
    mov ecx, 1

    ; Wrong if you want the element value:
    lea rbx, [rel arr + rcx*8]     ; rbx = address of arr[1]

    ; Correct load:
    mov rdx, [rel arr + rcx*8]     ; rdx = arr[1] value

    ; Demonstrate zero-extension:
    lea eax, [0xFFFFFFFF]          ; eax = 0xFFFFFFFF, rax becomes 0x00000000FFFFFFFF

    ; Exit status is arbitrary here; keep it 0
    mov eax, 60
    xor edi, edi
    syscall
