; Minimal CPUID example: query standard feature flags
; Output: ECX/EDX contain feature bits for EAX=1 (legacy feature leaf)

global cpuid_features
cpuid_features:
  mov eax, 1
  cpuid
  ; Now:
  ; EDX has legacy feature flags (e.g., bit 26 historically indicates SSE2)
  ; ECX has additional flags (e.g., bit 0 historically indicates SSE3)
  ret
