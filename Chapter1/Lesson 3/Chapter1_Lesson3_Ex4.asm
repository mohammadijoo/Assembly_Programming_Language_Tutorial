; SSE2 version (requires CPU support; most x86-64 machines have SSE2)
; void add_i32_sse2(int32_t* dst, const int32_t* a, const int32_t* b, size_t n)
; n assumed multiple of 4 for simplicity (tail handling is an exercise)
; rdi=dst, rsi=a, rdx=b, rcx=n

global add_i32_sse2
add_i32_sse2:
  xor r8, r8
.loop:
  cmp r8, rcx
  jae .done

  movdqu xmm0, [rsi + r8*4]   ; load 16 bytes (unaligned)
  movdqu xmm1, [rdx + r8*4]
  paddd xmm0, xmm1
  movdqu [rdi + r8*4], xmm0   ; store 16 bytes

  add r8, 4
  jmp .loop
.done:
  ret
