; AArch64 example: condition flags + conditional select (CSEL).
; Not NASM syntax. Shows modern ARM style: compare -> condition -> select.

    .text
    .global _start
_start:
    mov     w0, #10
    mov     w1, #20

    cmp     w0, w1              // sets NZCV for (w0 - w1)
    csel    w2, w0, w1, ge      // if w0 >= w1 then w2=w0 else w2=w1

    // Linux AArch64 exit: x8=93, x0=status, svc 0
    mov     x8, #93
    mov     x0, x2
    svc     #0
