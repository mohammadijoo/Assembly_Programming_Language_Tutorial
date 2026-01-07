memxor_scalar:
  ; RDI=dst, RSI=src, RDX=n
  test rdx, rdx
  jz .done
.loop:
  mov al, [rsi]
  xor [rdi], al
  inc rsi
  inc rdi
  dec rdx
  jnz .loop
.done:
  ret

memxor_sse2:
  ; Requires SSE2
  ; Process 16 bytes at a time using XMM0
  cmp rdx, 16
  jb  .tail
.vloop:
  movdqu xmm0, [rsi]
  movdqu xmm1, [rdi]
  pxor xmm1, xmm0
  movdqu [rdi], xmm1
  add rsi, 16
  add rdi, 16
  sub rdx, 16
  cmp rdx, 16
  jae .vloop
.tail:
  jmp memxor_scalar  ; reuse scalar for remainder

memxor_avx2:
  ; Requires AVX2 + OS support
  cmp rdx, 32
  jb  .tail
.vloop:
  vmovdqu ymm0, [rsi]
  vmovdqu ymm1, [rdi]
  vpxor ymm1, ymm1, ymm0
  vmovdqu [rdi], ymm1
  add rsi, 32
  add rdi, 32
  sub rdx, 32
  cmp rdx, 32
  jae .vloop
  vzeroupper        ; good hygiene when mixing AVX and SSE in many environments
.tail:
  jmp memxor_scalar
