; Example: check if rdi is zero (null pointer) without modifying it

test    rdi, rdi
jz      .is_null
; not null
jmp     .continue

.is_null:
; handle null case

.continue:
