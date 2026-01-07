; x86-64 SysV ABI (conceptual routine)
; void add_i32_scalar(int32_t* dst, const int32_t* a, const int32_t* b, size_t n)
; rdi=dst, rsi=a, rdx=b, rcx=n

global add_i32_scalar
add_i32_scalar:
  xor r8, r8                 ; i = 0
.loop:
  cmp r8, rcx
  jae .done
  mov eax, dword [rsi + r8*4]
  add eax, dword [rdx + r8*4]
  mov dword [rdi + r8*4], eax
  inc r8
  jmp .loop
.done:
  ret
