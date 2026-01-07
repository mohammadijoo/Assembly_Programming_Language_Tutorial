; NASM / x86-64
; Preconditions: CPUID leaf 1 indicates OSXSAVE=1
; Check if XCR0 enables XMM and YMM state (bits 1 and 2).

xor ecx, ecx        ; XCR index = 0
xgetbv              ; EDX:EAX = XCR0

; We want bits 1 and 2 set: mask = 0b110 = 6
mov ebx, eax
and ebx, 6
cmp ebx, 6
je  .avx_os_ok
; ... OS does not enable AVX state: do not execute AVX instructions

.avx_os_ok:
