; Typical shape of a leaf function (no calls), x86-64
; (Exact code depends on compiler, optimization level, and ABI.)

global add_two
add_two:
  ; input: edi (int32 a), esi (int32 b)
  lea eax, [rdi + rsi]    ; compute a + b
  ret
