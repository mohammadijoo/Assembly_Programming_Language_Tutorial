; Example: compare two signed integers (eax and ebx) and select a result

cmp     eax, ebx        ; sets flags based on (eax - ebx)
jl      .less           ; jump if eax < ebx (signed comparison)
; fall-through: eax >= ebx
mov     ecx, 1
jmp     .done

.less:
mov     ecx, -1

.done:
; ecx is now 1 if eax >= ebx, else -1
