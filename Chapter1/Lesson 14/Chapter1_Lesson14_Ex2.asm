; Debug assertion: crash fast if pointer is not 16-byte aligned
; You would justify the alignment requirement by reading the relevant instruction docs
; (e.g., aligned moves vs unaligned moves, or performance constraints).

global assert_align16
section .text
assert_align16:
    ; void assert_align16(void* p)
    ; SysV: p in RDI
    test rdi, 15
    jz .ok
    ud2                     ; guaranteed invalid opcode exception
.ok:
    ret
