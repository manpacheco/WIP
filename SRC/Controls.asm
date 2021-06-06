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
;;ld hl, posicion_y
;;ld b, (hl)
;;dec b
;;ld a, b
;;cp $FF
;;jr z, ScanAllKeys_reset_b
ScanAllKeys_reset_return:
;;ld (hl), b
ld b, 1
call Aumenta_inercia_x
halt
call Print_number
; jr ScanFinally


; ##########################################################
; ###################     DOWN       #######################
; ##########################################################
ScanDown:
ld bc, ROW_GFDSA			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
rra							; nos quedamos con el valor del bit más bajo
jr c, ScanRight				; si hay carry significa que la tecla no estaba pulsada
;;ld hl, posicion_y 		
;;ld b, (hl)
;;inc b
;;ld (hl), b
ld b, 1
call Disminuye_inercia_x
halt
call Print_number
;jr ScanFinally

; ##########################################################
; ###################     RIGHT       ######################
; ##########################################################
ScanRight:
ld bc, ROW_YUIOP			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
rra							; nos quedamos con el valor del bit más bajo
jr c, ScanLeft				; si hay carry significa que la tecla no estaba pulsada

;ld hl, posicion_x
;ld b, (hl)
;inc b
;ld (hl), b
;halt

call RotateRight
halt
;jr ScanFinally

; ##########################################################
; ###################     LEFT       #######################
; ##########################################################
ScanLeft:
ld bc, ROW_YUIOP			; en BC se carga la dirección completa donde está la fila del teclado
in a,(c)					; a la instrucción IN solo se le pasa la parte explicitamente el registro C porque la parte que está en el registro B ya está implícita
bit 1,a						; nos quedamos con el valor del 2º bit más bajo
jr nz, ScanFire		; si no es cero significa que la tecla no estaba pulsada

call RotateLeft

;ld hl, posicion_x 			
;ld b, (hl)
;ld a, 0
;cp b
;jr nz,ContinueLeft
;ld (hl), MAX_OFFSET_X
;jr ScanLeftMergeBranches

;ContinueLeft:
;dec b
;ld (hl), b
;ScanLeftMergeBranches:
halt

; ##########################################################
; ###################     FIRE       #######################
; ##########################################################
ScanFire:
ld bc, ROW_BNM_SymbolShift_Space
in a, (c)
rra
jr c, NothingPressed

;call MoveShip_X
;call MoveShip_Y
;call Print_number
jr ScanFinally

NothingPressed:

ScanFinally:
; out (254),a
ret

ScanAllKeys_reset_b:
ld b, 191
jr ScanAllKeys_reset_return