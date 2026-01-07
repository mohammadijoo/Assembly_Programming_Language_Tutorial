; NASM / x86-64
; Query CPUID leaf 1: basic feature flags.
; Outputs:
;   ECX and EDX contain feature bits for leaf 1.

xor ecx, ecx        ; subleaf = 0
mov eax, 1          ; leaf 1
cpuid               ; EAX, EBX, ECX, EDX updated

; Example checks (leaf 1):
; ECX bit 27 = OSXSAVE
; ECX bit 28 = AVX
; EDX bit 26 = SSE2

bt ecx, 27          ; test OSXSAVE
jc  .osxsave_set
; ... OSXSAVE not available

.osxsave_set:
bt ecx, 28          ; test AVX CPU capability
jc  .avx_cpu
; ... AVX not supported by CPU

.avx_cpu:
bt edx, 26          ; SSE2 present?
jc  .sse2_cpu
; ...
.sse2_cpu:
