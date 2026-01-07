\
; Chapter2_Lesson6_Ex4.asm
; MASM (ml64): minimal "no CRT" Windows x64 console program using ExitProcess.
;
; Build (Developer Command Prompt for VS):
;   ml64 /c /Zi /Fo:ex4.obj Chapter2_Lesson6_Ex4.asm
;   link /SUBSYSTEM:CONSOLE /ENTRY:main /DEBUG ex4.obj kernel32.lib
;
; Notes:
; - Windows x64 passes first integer argument in RCX.
; - ExitProcess never returns.

option casemap:none

EXTERN ExitProcess:PROC

.code
main PROC
    xor ecx, ecx            ; uExitCode = 0
    call ExitProcess
main ENDP
END
