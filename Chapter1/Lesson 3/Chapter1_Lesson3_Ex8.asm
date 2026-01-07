; int ct_equal(const uint8_t* a, const uint8_t* b, size_t n)
; Returns: EAX = 0 if equal, 1 if different
; SysV: rdi=a, rsi=b, rdx=n

global ct_equal
ct_equal:
  xor eax, eax            ; accumulator in AL (OR of diffs)
  test rdx, rdx
  jz .finish

.loop:
  mov r8b, [rdi]
  mov r9b, [rsi]
  xor r8b, r9b
  or  al, r8b

  inc rdi
  inc rsi
  dec rdx
  jnz .loop

.finish:
  test al, al
  setne al                ; AL=1 if any diff, else 0
  movzx eax, al
  ret
