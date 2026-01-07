\
; Chapter2_Lesson6_Ex15.asm
; Programming Exercise 3 (Starter): MASM function export for C (Windows x64).
; Goal: implement:
;   int memcmp_u8(const void* a, const void* b, size_t n);
; Return:
;   - negative if a is smaller at first differing byte
;   - zero if equal for n bytes
;   - positive if a is larger
;
; Windows x64 ABI:
;   RCX=a, RDX=b, R8=n, return EAX
;
; Build:
;   ml64 /c /Zi /Fo:ex15.obj Chapter2_Lesson6_Ex15.asm
;   (Link from a C test harness) link ex15.obj ...
;
; NOTE: This starter returns 0 unconditionally.

option casemap:none
PUBLIC memcmp_u8

.code
memcmp_u8 PROC
    xor eax, eax
    ret
memcmp_u8 ENDP
END
