global memcmp64
memcmp64:
  ; Preserve callee-saved if used (we won't use them here).
  xor eax, eax             ; default return 0
  test rdx, rdx
  je .eq

.loop:
  mov al, [rdi]            ; load byte A
  mov cl, [rsi]            ; load byte B (CL is caller-saved; ok)
  cmp al, cl
  jne .diff

  inc rdi
  inc rsi
  dec rdx
  jne .loop

.eq:
  xor eax, eax
  ret

.diff:
  ; unsigned byte compare result in flags from cmp al, cl
  ; if al < cl: CF=1 => return -1
  ; if al > cl: CF=0 and ZF=0 => return +1
  mov eax, 1
  jb .ret_neg
  ret

.ret_neg:
  mov eax, -1
  ret
