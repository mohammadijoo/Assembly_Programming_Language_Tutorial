bits 64
default rel

; Indexing an array of structs where element size is not a power of two.
; Demonstrates i*24 via LEA: i*24 = (i*3)*8.

global _start

struc NODE
    .key    resd 1      ; 4
    .pad    resd 1      ; 4  (keep qword alignment for next field)
    .value  resq 1      ; 8
    .next   resq 1      ; 8
endstruc
; NODE_size = 24

section .data
nodes:
    ; key, pad, value, next
    dd 1, 0
    dq 100
    dq 0

    dd 2, 0
    dq 200
    dq 0

    dd 3, 0
    dq 300
    dq 0

section .text
_start:
    mov ecx, 2                  ; i = 2 (third node)
    ; rax = i*3
    lea eax, [ecx + ecx*2]
    ; rax = i*24 = (i*3)*8
    lea rbx, [rel nodes + rax*8]

    ; Load nodes[i].value
    mov rax, [rbx + NODE.value] ; expected 300

    mov eax, 60
    mov edi, 44                 ; 300 mod 256 = 44
    syscall
