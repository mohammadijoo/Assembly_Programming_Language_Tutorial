; Returns EAX=1 if AVX2 safe, else EAX=0. (Skeleton)
global avx2_is_safe
section .text
avx2_is_safe:
  push rbx

  xor ecx, ecx
  mov eax, 1
  cpuid
  bt ecx, 27         ; OSXSAVE
  jnc .no
  bt ecx, 28         ; AVX
  jnc .no

  xor ecx, ecx
  xgetbv
  mov ebx, eax
  and ebx, 6
  cmp ebx, 6
  jne .no

  xor ecx, ecx
  mov eax, 7
  cpuid
  bt ebx, 5          ; AVX2
  jnc .no

  mov eax, 1
  pop rbx
  ret

.no:
  xor eax, eax
  pop rbx
  ret
