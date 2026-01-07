; rdi = head
; node layout:
;   +0: qword next
;   +8: dword value
;
; Load head->next->value into eax

mov rdi, qword [rdi + 0]      ; rdi = head->next
mov eax, dword [rdi + 8]      ; eax = rdi->value
