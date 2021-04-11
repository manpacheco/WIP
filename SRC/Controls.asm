ROW_54321 EQU 63486
ROW_67890 EQU 61438
ROW_TREWQ EQU 64510
ROW_GFDSA EQU 65022
ROW_HJKL_Enter EQU 49150
ROW_VCXZ_CapsShift EQU 65278
ROW_BNM_SymbolShift_Space EQU 32766

ScanAllKeys:

ScanUp:
ld bc, ROW_TREWQ ; en BC se carga la dirección completa donde está la fila del teclado
in a,(c) ; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque
; la parte que está en el registro B ya está implícita
rra ; nos quedamos con el valor del bit más bajo
jr c, NothingPressed ; si hay carry significa que la tecla no estaba pulsada

UpPressed:
ld hl, posicion_x
ld b, (hl)
inc b
ld (hl), b
halt
ld a,6 ; yellow
out (254),a
halt
ld a,6 ; yellow
out (254),a

jr ScanUpFinally

NothingPressed:
ld a,5 ; magenta

ScanUpFinally:
out (254),a
ret


