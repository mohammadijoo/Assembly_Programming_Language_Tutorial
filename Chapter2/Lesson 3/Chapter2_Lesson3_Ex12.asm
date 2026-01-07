; Pseudo-ABI: System V AMD64 example (Linux/macOS)
; Arguments:
;   RDI = dst, RSI = src, RDX = n
; Clobbers: caller-saved regs allowed; preserve RBX, RBP, R12-R15 if used.

global memxor_dispatch
global memxor_scalar
global memxor_sse2
global memxor_avx2

section .text

memxor_dispatch:
  ; Decide once per call (for simplicity). Production: cache decision.
  push rbx

  ; --- CPUID leaf 1 ---
  xor ecx, ecx
  mov eax, 1
  cpuid

  ; Check SSE2
  bt edx, 26
  jnc .use_scalar

  ; Check AVX + OSXSAVE
  bt ecx, 27
  jnc .use_sse2
  bt ecx, 28
  jnc .use_sse2

  ; XGETBV check for XMM+YMM
  xor ecx, ecx
  xgetbv
  mov ebx, eax
  and ebx, 6
  cmp ebx, 6
  jne .use_sse2

  ; --- CPUID leaf 7 subleaf 0 for AVX2 ---
  xor ecx, ecx
  mov eax, 7
  cpuid
  bt ebx, 5          ; AVX2 bit (leaf 7 EBX bit 5)
  jnc .use_sse2

  pop rbx
  jmp memxor_avx2

.use_sse2:
  pop rbx
  jmp memxor_sse2

.use_scalar:
  pop rbx
  jmp memxor_scalar
