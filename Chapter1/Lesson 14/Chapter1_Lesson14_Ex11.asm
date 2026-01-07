; Example snippet designed to produce a specific addressing mode:
; You can then use objdump/ndisasm to confirm the exact encoding.

global addrmode_demo
section .text
addrmode_demo:
    ; RDI points to int32 array, RSI is index
    ; Load arr[i] and arr[i+1] using scaled index addressing
    mov eax, [rdi + rsi*4]        ; base + index*scale
    mov edx, [rdi + rsi*4 + 4]    ; with displacement
    add eax, edx
    ret
