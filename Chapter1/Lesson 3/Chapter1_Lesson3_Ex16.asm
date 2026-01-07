; size_t strlen_rep(const char* s)
; SysV: rdi = s, return rax
; Uses: AL=0 as terminator, RCX as count, RDI advanced by SCASB

global strlen_rep
strlen_rep:
  xor eax, eax            ; AL = 0
  mov rcx, -1             ; "infinite" count
  repne scasb             ; scan for AL (0) in [rdi], increments rdi, decrements rcx
  not rcx                 ; rcx = bytes scanned including terminator
  dec rcx                 ; exclude terminator
  mov rax, rcx
  ret
