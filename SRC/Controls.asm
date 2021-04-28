ROW_54321 EQU 63486
ROW_67890 EQU 61438
ROW_TREWQ EQU 64510
ROW_YUIOP EQU 57342
ROW_GFDSA EQU 65022
ROW_HJKL_Enter EQU 49150
ROW_VCXZ_CapsShift EQU 65278
ROW_BNM_SymbolShift_Space EQU 32766

ScanAllKeys:

; ##########################################################
; ####################     UP       ########################
; ##########################################################
ScanUp:
ld bc, ROW_TREWQ 			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c) 					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
rra 						; nos quedamos con el valor del bit más bajo
jr c, ScanDown 				; si hay carry significa que la tecla no estaba pulsada
ld hl, posicion_y
ld b, (hl)
dec b
ld (hl), b
halt
ld a,6 ; yellow
; jr ScanFinally


; ##########################################################
; ###################     DOWN       #######################
; ##########################################################
ScanDown:
ld bc, ROW_GFDSA			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
rra							; nos quedamos con el valor del bit más bajo
jr c, ScanRight		; si hay carry significa que la tecla no estaba pulsada
ld hl, posicion_y
ld b, (hl)
inc b
ld (hl), b
halt
ld a,4 ; verde
;jr ScanFinally

; ##########################################################
; ###################     RIGHT       ######################
; ##########################################################
ScanRight:
ld bc, ROW_YUIOP			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
rra							; nos quedamos con el valor del bit más bajo
jr c, ScanLeft		; si hay carry significa que la tecla no estaba pulsada
ld hl, posicion_x
ld b, (hl)
inc b
ld (hl), b
halt
ld a,7 ; blanco
;jr ScanFinally

; ##########################################################
; ###################     LEFT       #######################
; ##########################################################
ScanLeft:
ld bc, ROW_YUIOP			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
bit 1,a						; nos quedamos con el valor del 2º bit más bajo
jr nz, NothingPressed		; si no es cero significa que la tecla no estaba pulsada
ld hl, posicion_x
ld b, (hl)
ld a, 0
cp b
jr nz,ContinueLeft
ld (hl), MAX_OFFSET_X
jr ScanLeftMergeBranches

ContinueLeft:
dec b
ld (hl), b
ScanLeftMergeBranches:
halt
ld a,7 ; blanco
jr ScanFinally

NothingPressed:
ld a,3 ; magenta

ScanFinally:
out (254),a
ret