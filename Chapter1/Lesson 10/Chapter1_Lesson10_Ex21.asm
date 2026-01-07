; Sequence: compute *(rdi) + 7, compare to 100, branch, return.
global seqA
section .text
seqA:
    mov eax, dword [rdi]
    add eax, 7
    cmp eax, 100
    jl  .less
    mov eax, 1
    ret
.less:
    xor eax, eax
    ret
