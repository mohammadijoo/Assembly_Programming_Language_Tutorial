; masm_surface.asm (illustrative patterns)
option casemap:none

.data
counter dq 0

.code
; MASM-style procedure block (explicit)
inc_counter proc
    inc qword ptr [counter]
    ret
inc_counter endp

end