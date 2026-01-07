; Direct control flow
jmp  label_target
call function_entry
ret

; Indirect control flow (RIP ← register or memory target)
jmp  rax
call [rbx]
