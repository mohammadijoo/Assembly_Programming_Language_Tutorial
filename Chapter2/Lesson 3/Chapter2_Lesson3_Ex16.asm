; Clean solution using R8 (caller-saved in SysV):
global mul_add_u64
mul_add_u64:
  mov rcx, rdx          ; c
  mov rax, rdi
  mul rsi               ; RDX:RAX = a*b
  add rax, rcx
  setc r8b              ; r8b = carry from low addition
  adc rdx, 0            ; incorporate carry into high half (architecturally correct)

  ; Return carry bit in RDX as 0/1 (not the high half):
  movzx edx, r8b        ; EDX = 0/1, zero-extended to RDX
  ret
