; Suppose a struct layout (conceptual):
;   offset 0:  int32 id
;   offset 4:  int32 flags
;   offset 8:  int64 ptr
;
; rbx = pointer to struct

mov eax, dword [rbx + 0]      ; id
mov ecx, dword [rbx + 4]      ; flags
mov rdx, qword [rbx + 8]      ; ptr
