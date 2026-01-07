; SysV AMD64:
; RDI=a, RSI=b, RDX=c
; Returns:
;   RAX = (a*b + c) mod 2^64
;   RDX = carry-out (0/1) of the 128-bit accumulation

global mul_add_u64
section .text

mul_add_u64:
  ; Compute 128-bit product in RDX:RAX using MUL (implicit RAX)
  mov rax, rdi
  mul rsi               ; RDX:RAX = a*b

  ; Add c to low half; ADC into high half
  add rax, rdx          ; WARNING: RDX currently holds high half; we need c in another reg
  ; Fix: reload c before MUL clobbers it (caller passed c in RDX). Use RCX.

; Corrected version:
global mul_add_u64_fixed
mul_add_u64_fixed:
  mov rcx, rdx          ; save c
  mov rax, rdi
  mul rsi               ; RDX:RAX = a*b
  add rax, rcx
  adc rdx, 0            ; propagate carry from low add into high
  ; Now RDX is the high 64-bit of (a*b + c). Carry-out bit is whether high != 0? Not always.
  ; We want carry-out of 128-bit sum: since product already 128-bit, adding 64-bit c can only carry into high by 1.
  ; carry-out beyond 128 bits cannot occur. So "carry-out bit" here is just the carry into high half from low addition.
  ; That carry is exactly CF after add. We propagated it via ADC rdx,0; but we also need the carry bit itself.

  ; Extract carry bit from CF: use SETC into a byte register
  setc al               ; clobbers AL (part of result) - not acceptable
  ; Better: use a separate byte reg and then widen.
