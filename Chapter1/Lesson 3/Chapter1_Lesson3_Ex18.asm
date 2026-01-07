; void lock_u32(uint32_t* L)
; SysV: rdi = L

global lock_u32
lock_u32:
.try:
  mov eax, 1
  xchg eax, dword [rdi]    ; atomic: eax <- old, [rdi] <- 1
  test eax, eax
  jz .acquired

.spin:
  pause                    ; polite spin (reduces power + contention)
  cmp dword [rdi], 0
  jne .spin
  jmp .try

.acquired:
  ret

; void unlock_u32(uint32_t* L)
global unlock_u32
unlock_u32:
  mov dword [rdi], 0
  ret
