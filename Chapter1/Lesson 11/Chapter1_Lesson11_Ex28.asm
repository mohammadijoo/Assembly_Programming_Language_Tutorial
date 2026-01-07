; BUGGY x86-64 snippet (intended SysV)
; RDI = p, RSI = i
push rbp
mov rbp, rsp
mov eax, edi
lea eax, [eax + esi*8]
mov rax, [eax]
pop rbp
ret
