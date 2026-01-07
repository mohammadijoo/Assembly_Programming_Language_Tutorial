; Compare two registers; flags set based on (rdi - rsi)
cmp rdi, rsi

; Convert condition into 0/1 in a byte register
; sete writes 1 if ZF=1 else 0
sete al

; signed less-than: setl uses SF xor OF
setl bl

; unsigned below: setb uses CF
setb cl
