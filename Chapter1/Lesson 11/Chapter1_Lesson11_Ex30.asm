; uint32_t load_elem32(const uint32_t* p, size_t i)
global load_elem32_sysv
load_elem32_sysv:
    mov eax, dword [rdi + rsi*4]  ; returns in EAX, zero-extends into RAX
    ret
