; it can be loaded at the first sector of a floppy disk:

;   cylinder: 0
;   sector: 1
;   head: 0

; boot record is loaded at 0000:7c00
org 7c00h

; initialize the stack:
mov     ax, 07c0h
mov     ss, ax
mov     sp, 03feh ; top of the stack.


; set data segment:
xor     ax, ax
mov     ds, ax

; set default video mode 80x25:
mov     ah, 00h
mov     al, 03h
int     10h

; print welcome message:
lea     si, msg
call    print_string

; load the kernel at 0800h:0000h
; 10 sectors starting at:
;   cylinder: 0
;   sector: 2
;   head: 0


mov     ah, 02h ; read function.
mov     al, 10  ; sectors to read.
mov     ch, 0   ; cylinder.
mov     cl, 2   ; sector.
mov     dh, 0   ; head.

mov     bx, 0800h   
mov     es, bx
mov     bx, 0

; read!
int     13h


; integrity check:
cmp     es:[0000],0E9h  ; first byte of kernel must be 0E9 (jmp).
je     integrity_check_ok

; integrity check error
lea     si, err
call    print_string

; wait for any key...
mov     ah, 0
int     16h

; store magic value at 0040h:0072h:
;   0000h - cold boot.
;   1234h - warm boot.
mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h ; cold boot.
jmp	0ffffh:0000h	     ; reboot!


integrity_check_ok:
; pass control to kernel:
jmp     0800h:0000h




print_string proc near
push    ax      ; store registers...
push    si      ;
next_char:      
        mov     al, [si]
        cmp     al, 0
        jz      printed
        inc     si
        mov     ah, 0eh ; teletype function.
        int     10h
        jmp     next_char
printed:
pop     si      ; re-store registers...
pop     ax      ;
ret
print_string endp

                       
                       
                       
;==== data section =====================

msg  db "Loading...",0Dh,0Ah, 0 
     
err  db "invalid data at sector: 2, cylinder: 0, head: 0 - integrity check failed.", 0Dh,0Ah
     db "refer to tutorial 11 - making your own operating system.", 0Dh,0Ah
     db "System will reboot now. Press any key...", 0
    
