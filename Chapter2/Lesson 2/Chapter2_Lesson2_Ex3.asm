; Protected-mode conceptual load:
; linear = base(DS.selector) + EA
; CPU checks EA <= limit(DS.selector) and access rights.

mov eax, [ebx+4]     ; DS is default if base reg is not EBP/ESP
mov eax, [ebp+8]     ; SS is default because EBP is used (stack frame)
