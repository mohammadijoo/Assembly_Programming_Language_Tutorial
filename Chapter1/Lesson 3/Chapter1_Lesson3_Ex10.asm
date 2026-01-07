; int64_t dot_i32(const int32_t* a, const int32_t* b, uint32_t n)
; SysV: rdi=a, rsi=b, edx=n
; Return: rax (int64)

global dot_i32
dot_i32:
  xor rax, rax            ; sum = 0
  xor ecx, ecx            ; i = 0

.loop:
  cmp ecx, edx
  jae .done

  movsxd r8, dword [rdi + rcx*4]   ; load a[i] as signed 64-bit
  movsxd r9, dword [rsi + rcx*4]   ; load b[i] as signed 64-bit
  imul r8, r9                      ; r8 = a[i]*b[i]
  add rax, r8

  inc ecx
  jmp .loop

.done:
  ret
