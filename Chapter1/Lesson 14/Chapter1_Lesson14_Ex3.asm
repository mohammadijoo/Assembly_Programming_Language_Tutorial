; Minimal CPUID probe pattern (illustrative)
; Inputs: EAX=leaf, ECX=subleaf
; Outputs: EAX, EBX, ECX, EDX overwritten
; Note: On SysV AMD64, RBX is callee-saved. CPUID clobbers EBX/RBX, so preserve it.

global cpuid_leaf
section .text
cpuid_leaf:
    ; void cpuid_leaf(uint32_t leaf, uint32_t subleaf, uint32_t* out_eax, uint32_t* out_ebx, uint32_t* out_ecx, uint32_t* out_edx)
    ; SysV: leaf=EDI, subleaf=ESI, out ptrs in RDX, RCX, R8, R9
    push rbx
    mov eax, edi
    mov ecx, esi
    cpuid
    mov [rdx], eax
    mov [rcx], ebx
    mov [r8],  ecx
    mov [r9],  edx
    pop rbx
    ret
