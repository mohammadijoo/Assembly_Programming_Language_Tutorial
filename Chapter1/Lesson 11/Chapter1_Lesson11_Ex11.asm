; x86 (32-bit), caller side for cdecl
push dword 7
push dword 5
call add2
add  esp, 8        ; caller cleans
; EAX holds return value
