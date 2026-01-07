; Input:
;   RBX = offset pointer (same offset used for all three loads)
;   RDI = output buffer pointer (must remain unchanged on return)
; Output:
;   [RDI+0]  = qword [RBX]      (default segment)
;   [RDI+8]  = qword [FS:RBX]
;   [RDI+16] = qword [GS:RBX]
; Preserves: RBX, RDI
; Clobbers:  RAX, RCX, RDX

push rbx
push rdi

mov rax, [rbx]
mov rcx, [fs:rbx]
mov rdx, [gs:rbx]

; Store to the *saved* RDI value on stack
; Stack layout (top):
;   [rsp+0] = saved rdi
;   [rsp+8] = saved rbx
mov rdi, [rsp+0]
mov [rdi+0],  rax
mov [rdi+8],  rcx
mov [rdi+16], rdx

pop rdi
pop rbx
ret
