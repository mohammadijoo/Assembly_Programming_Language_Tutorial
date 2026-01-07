; lea can compute linear expressions base + index*scale + disp without touching memory.
; This is not “magic”; it is simply a different encoding and execution behavior.

lea rax, [rbx + rcx*4 + 16]
