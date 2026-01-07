; Linux x86-64 (NASM/Intel) - strlen + print decimal length
; This solution intentionally uses only syscalls and integer instructions.

%define SYS_write 1
%define SYS_exit  60
%define FD_STDOUT 1

section .rodata
msg:      db "Count my length", 10, 0     ; include newline, then NUL
msg_text: db "len=", 0
nl:       db 10

section .bss
outbuf:   resb 32                          ; buffer for decimal length

section .text
global _start

; size_t strlen_u(const char* s)
; input:  rdi = s
; output: rax = length (bytes before NUL)
strlen_u:
  xor eax, eax               ; rax = 0 (count)
.L_loop:
  cmp byte [rdi+rax], 0
  je .L_done
  inc rax
  jmp .L_loop
.L_done:
  ret

; u64 to decimal ASCII into outbuf (no leading zeros), returns:
; rsi = pointer to first digit, rdx = number of digits
; input: rax = value
utoa_dec:
  lea rbx, [rel outbuf+31]   ; write digits backwards
  mov byte [rbx], 0          ; terminator (not printed)
  xor rcx, rcx               ; digit count = 0
  mov r8, 10

  cmp rax, 0
  jne .L_conv
  dec rbx
  mov byte [rbx], '0'
  mov rcx, 1
  jmp .L_finish

.L_conv:
  ; while (rax != 0) { q = rax/10; rem = rax%10; store '0'+rem; rax=q; }
.L_divloop:
  xor edx, edx               ; rdx:rax / 10
  div r8                     ; quotient in rax, remainder in rdx
  add dl, '0'
  dec rbx
  mov [rbx], dl
  inc rcx
  test rax, rax
  jne .L_divloop

.L_finish:
  mov rsi, rbx               ; start pointer
  mov rdx, rcx               ; length
  ret

_start:
  ; Compute strlen of msg (excluding NUL, includes newline)
  lea rdi, [rel msg]
  call strlen_u              ; rax = len

  ; Print msg itself
  mov rdx, rax
  mov eax, SYS_write
  mov edi, FD_STDOUT
  lea rsi, [rel msg]
  syscall

  ; Print "len="
  mov eax, SYS_write
  mov edi, FD_STDOUT
  lea rsi, [rel msg_text]
  mov edx, 4
  syscall

  ; Convert length in rax to decimal and print
  call utoa_dec
  mov eax, SYS_write
  mov edi, FD_STDOUT
  syscall

  ; Print newline
  mov eax, SYS_write
  mov edi, FD_STDOUT
  lea rsi, [rel nl]
  mov edx, 1
  syscall

  ; exit(0)
  mov eax, SYS_exit
  xor edi, edi
  syscall