; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Exercise 3 (Solution): cdecl-to-stdcall adapter on x86 32-bit (Linux i386)
; We implement a stdcall target that cleans its args (ret 8), and a cdecl adapter
; that can be called by cdecl callers (caller will clean adapter args).
;
; Build (Linux 32-bit environment):
;   nasm -felf32 Chapter6_Lesson6_Ex12.asm -o ex12.o
;   ld -m elf_i386 -o ex12 ex12.o
; Run:
;   ./ex12 ; exit status is 40 + 2 = 42

BITS 32
GLOBAL _start

SECTION .text

; int __stdcall stdcall_add2(int a, int b)
stdcall_add2:
    mov eax, [esp+4]
    add eax, [esp+8]
    ret 8                   ; callee cleanup

; int __cdecl cdecl_call_stdcall_adapter(int a, int b)
; Adapter itself uses cdecl: caller will clean the adapter's args.
cdecl_call_stdcall_adapter:
    mov eax, [esp+4]        ; a
    mov edx, [esp+8]        ; b
    push edx
    push eax
    call stdcall_add2        ; stdcall callee cleaned (popped 8 bytes)
    ret                      ; return to cdecl caller (caller cleans its own 8 bytes)

_start:
    push dword 2
    push dword 40
    call cdecl_call_stdcall_adapter
    add esp, 8              ; cdecl caller cleanup for adapter args

    mov ebx, eax
    mov eax, 1
    int 0x80
