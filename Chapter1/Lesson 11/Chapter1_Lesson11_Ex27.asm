; uint32_t my_strlen(const char* s)
; [EBP+8] = s, return EAX
global my_strlen_cdecl
my_strlen_cdecl:
    push ebp
    mov  ebp, esp

    mov  edx, [ebp+8]   ; s
    xor  eax, eax       ; len = 0

.loop:
    cmp  byte [edx + eax], 0
    je   .done
    inc  eax
    jmp  .loop

.done:
    mov  esp, ebp
    pop  ebp
    ret
