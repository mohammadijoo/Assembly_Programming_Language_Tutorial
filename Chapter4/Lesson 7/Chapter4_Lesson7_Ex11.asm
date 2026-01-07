BITS 64
default rel
global _start

section .data
arr dd -10, -3, 0, 4, 7, 9, 15, 21, 100
n   equ ($ - arr) / 4
key dd 15

section .text
_start:
    ; Exercise solution: iterative binary search on sorted int32 array.
    ; Returns:
    ;   EAX = index if found, or -1 if not found.
    ; Exits with status 0 if found, 1 if not found.

    xor eax, eax            ; low = 0
    mov edx, n
    dec edx                 ; high = n-1

.loop:
    cmp eax, edx
    jg  .not_found          ; while (low <= high)

    ; mid = (low + high) / 2
    mov ecx, eax
    add ecx, edx
    shr ecx, 1

    ; v = arr[mid]
    mov esi, dword [rel key]
    mov ebx, dword [rel arr + rcx*4]

    cmp ebx, esi
    je  .found
    jl  .go_right           ; v < key => low = mid+1 (signed compare)
    ; v > key => high = mid-1
    lea edx, [ecx-1]
    jmp .loop

.go_right:
    lea eax, [ecx+1]
    jmp .loop

.found:
    mov eax, ecx
    xor edi, edi
    jmp .exit

.not_found:
    mov eax, -1
    mov edi, 1

.exit:
    mov eax, 60
    syscall
