; Example: isolate a flags-dependent region (SysV x86-64, NASM Intel syntax)
; Rule from ISA docs: CMP sets flags; LEA does not set flags; ADD sets flags.

global is_equal_32
section .text
is_equal_32:
    ; int is_equal_32(int a, int b)  -> return 1 if equal else 0
    ; SysV: a in EDI, b in ESI, return in EAX
    cmp edi, esi            ; sets ZF if equal
    sete al                 ; AL = (ZF==1)
    movzx eax, al           ; zero-extend
    ret
