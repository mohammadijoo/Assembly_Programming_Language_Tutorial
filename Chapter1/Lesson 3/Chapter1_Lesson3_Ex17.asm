; void* memmove_u8(void* dst, const void* src, size_t n)
; SysV: rdi=dst, rsi=src, rdx=n, return rax=dst
; Copies bytes; correct overlap handling using DF.

global memmove_u8
memmove_u8:
  mov rax, rdi
  test rdx, rdx
  jz .done

  ; If dst == src, nothing to do
  cmp rdi, rsi
  je .done

  ; If dst < src, forward copy is safe
  jb .forward

  ; If dst >= src:
  ; If dst >= src + n, forward is safe; else overlap -> backward copy
  mov rcx, rsi
  add rcx, rdx
  cmp rdi, rcx
  jae .forward

.backward:
  ; Copy from end: set pointers to last byte
  lea rdi, [rdi + rdx - 1]
  lea rsi, [rsi + rdx - 1]
  mov rcx, rdx
  std                   ; DF=1, string ops decrement
  rep movsb
  cld                   ; restore DF=0 for ABI hygiene
  jmp .done

.forward:
  mov rcx, rdx
  cld
  rep movsb

.done:
  ret
