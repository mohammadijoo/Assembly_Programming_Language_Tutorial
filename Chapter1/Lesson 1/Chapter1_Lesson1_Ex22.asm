; int32_t clamp_i32(int32_t x, int32_t lo, int32_t hi)
; edi = x, esi = lo, edx = hi
; eax = result
clamp_i32:
  mov eax, edi        ; eax = x

  ; if (eax < lo) eax = lo;
  cmp eax, esi
  cmovl eax, esi

  ; if (eax > hi) eax = hi;
  cmp eax, edx
  cmovg eax, edx

  ret