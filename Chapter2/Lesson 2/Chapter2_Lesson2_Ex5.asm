; Default segment behavior (Intel syntax, conceptual):
mov eax, [rbx]        ; default segment: DS (or flat base 0 in long mode)
mov eax, [rbp+16]     ; default segment: SS

; Segment override (FS/GS are commonly meaningful in long mode):
mov rax, [fs:rbx]     ; use FS instead of default
mov rax, [gs:rbp+8]   ; use GS even though base reg is RBP (would default to SS)
