; x86 (32-bit) PIC-style "call/pop" to discover EIP
; This is a classic technique for position-independent computations.

get_eip:
    call .next
.next:
    pop eax         ; EAX now holds address of label .next (approximate EIP)
    ret
