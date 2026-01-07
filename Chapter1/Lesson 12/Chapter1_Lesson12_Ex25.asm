; u64_sum_masm.asm (MS x64)
; a in rcx, n in rdx, return in rax
option casemap:none
.code

u64_sum proc
    xor rax, rax
    test rdx, rdx
    jz done

loop_start:
    add rax, qword ptr [rcx]
    add rcx, 8
    dec rdx
    jnz loop_start

done:
    ret
u64_sum endp

end