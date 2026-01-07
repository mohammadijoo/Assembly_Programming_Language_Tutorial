; Intentionally trap if an invariant is violated.
cmp rdi, 0
jne .ok
ud2                 ; guaranteed invalid instruction fault
.ok:
