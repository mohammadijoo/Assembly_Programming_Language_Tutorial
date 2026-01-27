; Chapter5_Lesson10_Ex7.asm
; Defensive Control Flow — Syscall Wrapper with Validation + Error Mapping
; Linux x86-64 syscall ABI (compatible with SysV function calling convention for args)
;
; int64_t write_checked(int32_t fd, const void* buf, uint64_t count, uint32_t* err_out);
;   edi = fd
;   rsi = buf
;   rdx = count
;   rcx = err_out (optional)
; Returns:
;   rax = bytes written on success
;   rax = -1 on error
; Side effect:
;   *err_out = 0 on success, else positive errno value (EINVAL on precheck failure)
;
; Policy:
; - Rejects NULL buf when count != 0
; - Rejects negative fd
; - Rejects count larger than MAX_COUNT (defensive cap)

BITS 64
default rel

%define SYS_write 1
%define MAX_COUNT 1048576
%define EINVAL 22

global write_checked
section .text

write_checked:
    ; Precheck: negative fd?
    test edi, edi
    js   .invalid

    ; Precheck: buf NULL with count non-zero?
    test rdx, rdx
    jz   .ok_to_call               ; count=0: allow NULL buffer
    test rsi, rsi
    jz   .invalid

.ok_to_call:
    cmp  rdx, MAX_COUNT
    ja   .invalid

    mov  eax, SYS_write
    syscall

    test rax, rax
    jns  .success                  ; rax >= 0

    ; Linux returns -errno
    neg  rax                       ; rax = errno (positive)
    test rcx, rcx
    jz   .ret_minus1
    mov  dword [rcx], eax
.ret_minus1:
    mov  rax, -1
    ret

.success:
    test rcx, rcx
    jz   .ret_ok
    mov  dword [rcx], 0
.ret_ok:
    ret

.invalid:
    test rcx, rcx
    jz   .ret_minus1b
    mov  dword [rcx], EINVAL
.ret_minus1b:
    mov  rax, -1
    ret
