; SysV AMD64
global load_or_zero
load_or_zero:
  ; No callee-saved registers used, so no prologue needed.
  ; Compute candidate address and candidate load, then mask via conditional move.

  ; Default result = 0
  xor eax, eax

  ; Compare idx vs len (unsigned)
  cmp rsi, rdx
  jae .done                 ; (Optional) If you want strictly no branch, remove this jump.
                            ; We will provide a strictly branchless variant below.

  mov rax, [rdi + rsi*8]
.done:
  ret
