; hello_masm.asm (Windows x64, MASM)
; Assemble: ml64.exe /c /Fo hello_masm.obj hello_masm.asm
; Link:     link.exe /SUBSYSTEM:CONSOLE /ENTRY:main hello_masm.obj kernel32.lib

option casemap:none

extrn GetStdHandle:proc
extrn WriteFile:proc
extrn ExitProcess:proc

includelib kernel32.lib

STD_OUTPUT_HANDLE equ -11

.data
msg        db "Hello from MASM (Win64)!", 13, 10
msg_len    equ ($ - msg)

.code
main proc
    ; Allocate shadow space (32 bytes) + 8 for 16-byte alignment = 0x28
    sub rsp, 28h

    ; HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov rcx, rax                ; rcx = h (arg1 for WriteFile)

    ; BOOL WriteFile(h, msg, msg_len, &bytesWritten, NULL);
    lea rdx, msg                ; rdx = buffer (arg2)
    mov r8d, msg_len            ; r8  = length (arg3)
    lea r9,  [rsp+1Ch]          ; r9  = &bytesWritten (arg4), stored in shadow
    mov dword ptr [rsp+1Ch], 0  ; initialize bytesWritten
    mov qword ptr [rsp+20h], 0  ; 5th arg (lpOverlapped) on stack
    call WriteFile

    ; ExitProcess(0);
    xor ecx, ecx
    call ExitProcess

    add rsp, 28h
    ret
main endp
end