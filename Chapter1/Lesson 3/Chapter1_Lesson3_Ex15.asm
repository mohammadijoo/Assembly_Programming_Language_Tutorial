; int32_t abs32(int32_t x)
; SysV: edi = x, return eax

global abs32
abs32:
  mov eax, edi
  mov edx, eax
  sar edx, 31          ; edx = 0x00000000 if x>=0 else 0xFFFFFFFF
  xor eax, edx
  sub eax, edx         ; if x<0: eax = (~x)+1 = -x ; if x>=0: unchanged
  ret

; Note: if x = 0x80000000 (-2^31), -x overflows 32-bit signed range.
; The computation returns 0x80000000, which is consistent with two's complement wraparound.
