; Prologue/epilogue (classic shape)
push rbp
mov  rbp, rsp
sub  rsp, 32              ; allocate local space (alignment matters)

; ... body ...

add  rsp, 32
pop  rbp
ret
