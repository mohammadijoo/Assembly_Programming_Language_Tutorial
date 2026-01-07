BITS 64
default rel
global _start

section .data
; Tiny bytecode VM program:
;   acc = 3
;   loop rcx=5:
;       acc = acc - 1
;   halt
;
; Opcodes:
;   0x10 IMM8:  acc = sign_extend(imm8)
;   0x20 IMM8:  acc += sign_extend(imm8)
;   0x21 IMM8:  acc -= sign_extend(imm8)
;   0x30 REL8:  jmp  pc += sign_extend(rel8)
;   0x31 REL8:  jz   if acc==0 then pc += rel8
;   0x32 REL8:  jnz  if acc!=0 then pc += rel8
;   0x40 REL8:  loop if (--rcx)!=0 then pc += rel8
;   0x00:       halt
program:
    db 0x10, 3          ; acc = 3
    db 0x40, 4          ; loop +4 bytes forward (to SUB)
    db 0x00             ; (should never reach directly)
    db 0x00             ; padding
    db 0x21, 1          ; acc -= 1
    db 0x30, -4         ; jmp back to LOOP
    db 0x00             ; halt
program_len equ $ - program

dispatch:
    dq op_halt          ; 0x00
    times 0x0F dq op_bad
    dq op_imm           ; 0x10
    times 0x0F dq op_bad
    dq op_add           ; 0x20
    dq op_sub           ; 0x21
    times 0x0E dq op_bad
    dq op_jmp           ; 0x30
    dq op_jz            ; 0x31
    dq op_jnz           ; 0x32
    times 0x0D dq op_bad
    dq op_loop          ; 0x40

section .text
_start:
    lea rsi, [rel program]    ; pc
    xor rax, rax              ; acc
    mov ecx, 5                ; loop counter for opcode 0x40

.fetch:
    ; bounds check: pc within [program, program+len)
    lea rbx, [rel program]
    cmp rsi, rbx
    jb  .trap
    lea rdx, [rel program + program_len]
    cmp rsi, rdx
    jae .trap

    mov bl, [rsi]             ; opcode
    inc rsi

    ; range check for dispatch table: only support opcodes up to 0x40
    cmp bl, 0x40
    ja  op_bad

    ; computed dispatch: jmp [dispatch + opcode*8]
    movzx rbx, bl
    jmp qword [rel dispatch + rbx*8]

op_imm:
    movsx rdx, byte [rsi]
    inc rsi
    mov rax, rdx
    jmp .fetch

op_add:
    movsx rdx, byte [rsi]
    inc rsi
    add rax, rdx
    jmp .fetch

op_sub:
    movsx rdx, byte [rsi]
    inc rsi
    sub rax, rdx
    jmp .fetch

op_jmp:
    movsx rdx, byte [rsi]
    inc rsi
    add rsi, rdx
    jmp .fetch

op_jz:
    movsx rdx, byte [rsi]
    inc rsi
    test rax, rax
    jnz .fetch
    add rsi, rdx
    jmp .fetch

op_jnz:
    movsx rdx, byte [rsi]
    inc rsi
    test rax, rax
    jz  .fetch
    add rsi, rdx
    jmp .fetch

op_loop:
    movsx rdx, byte [rsi]
    inc rsi
    dec rcx
    jz  .fetch
    add rsi, rdx
    jmp .fetch

op_halt:
    ; exit( acc & 0xFF )
    mov edi, eax
    mov eax, 60
    syscall

op_bad:
    mov eax, 60
    mov edi, 2
    syscall

.trap:
    mov eax, 60
    mov edi, 3
    syscall
