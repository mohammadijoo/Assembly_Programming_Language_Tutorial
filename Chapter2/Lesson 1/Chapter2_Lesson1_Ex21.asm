; Branchless load with safe redirection.
; Requires a valid pointer to a zero qword in RCX (or synthesize via stack/local).
; Interface variant:
;   RDI=base, RSI=idx, RDX=len, RCX=&zero_qword
; Returns RAX = base[idx] if idx<len else 0.

global load_or_zero_safe
load_or_zero_safe:
  ; r8 = base + idx*8
  lea r8, [rdi + rsi*8]

  ; Compare idx vs len (unsigned)
  cmp rsi, rdx

  ; If idx >= len, replace r8 with &zero_qword
  cmovae r8, rcx

  ; Always safe to load now
  mov rax, [r8]
  ret
