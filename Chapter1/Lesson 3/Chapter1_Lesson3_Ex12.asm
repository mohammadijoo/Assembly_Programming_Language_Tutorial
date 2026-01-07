; uint32_t atomic_inc_u32(volatile uint32_t* p)
; Returns the incremented value.
; SysV: rdi = p

global atomic_inc_u32
atomic_inc_u32:
  mov eax, 1
  lock xadd dword [rdi], eax   ; EAX gets old value; memory gets old+1
  inc eax                      ; return new value
  ret
