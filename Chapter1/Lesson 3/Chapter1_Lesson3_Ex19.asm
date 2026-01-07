; void add_i32_sse2_tail(int32_t* dst, const int32_t* a, const int32_t* b, size_t n)
; SysV: rdi=dst, rsi=a, rdx=b, rcx=n

global add_i32_sse2_tail
add_i32_sse2_tail:
  xor r8, r8                 ; i = 0

  ; Vector part: process while i+4 <= n
.vloop:
  mov r9, rcx
  sub r9, r8
  cmp r9, 4
  jb .tail

  movdqu xmm0, [rsi + r8*4]
  movdqu xmm1, [rdx + r8*4]
  paddd xmm0, xmm1
  movdqu [rdi + r8*4], xmm0

  add r8, 4
  jmp .vloop

.tail:
  cmp r8, rcx
  jae .done

  mov eax, dword [rsi + r8*4]
  add eax, dword [rdx + r8*4]
  mov dword [rdi + r8*4], eax
  inc r8
  jmp .tail

.done:
  ret
