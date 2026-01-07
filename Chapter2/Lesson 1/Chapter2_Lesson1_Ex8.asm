; Save RFLAGS to stack and restore later
pushfq
; ... code that clobbers flags ...
popfq
