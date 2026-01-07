; void secure_bzero(void* p, size_t n)
; rdi=p, rsi=n

global secure_bzero
secure_bzero:
  xor eax, eax
  mov rcx, rsi
  rep stosb               ; fill [rdi..rdi+rcx) with AL=0
  ret
