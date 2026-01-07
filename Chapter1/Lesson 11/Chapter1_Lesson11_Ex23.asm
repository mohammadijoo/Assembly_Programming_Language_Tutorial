; x86 (32-bit) cdecl:
; int64_t sum_i32(const int32_t* a, uint32_t n)
; Stack:
;   [EBP+8]  = a
;   [EBP+12] = n
; Return: EDX:EAX as 64-bit signed sum (common ABI pattern)

global sum_i32_cdecl
sum_i32_cdecl:
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi

    mov  edi, [ebp+8]       ; a
    mov  ecx, [ebp+12]      ; n

    xor  eax, eax           ; low 32
    xor  edx, edx           ; high 32

    test ecx, ecx
    jz .done

.loop:
    mov  ebx, [edi]         ; load int32
    cdq                     ; sign-extend EAX into EDX (but EBX has value, so do manual)
    ; Manual sign-extend EBX into a temporary pair (t_high:t_low) in ESI:EBX
    mov  esi, ebx
    sar  esi, 31            ; ESI = 0x00000000 or 0xFFFFFFFF

    add  eax, ebx           ; add low
    adc  edx, esi           ; add high with carry

    add  edi, 4
    dec  ecx
    jnz .loop

.done:
    pop  edi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret
