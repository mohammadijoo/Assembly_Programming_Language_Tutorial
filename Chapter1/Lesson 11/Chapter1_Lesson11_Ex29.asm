; Correct x86-64 SysV:
; uint64_t load_elem(const uint64_t* p, size_t i)
; RDI = p, RSI = i, return RAX = p[i]
global load_elem_sysv
load_elem_sysv:
    mov rax, [rdi + rsi*8]
    ret
