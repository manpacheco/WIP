VRAM_ADDRESS EQU 16384
Offset_X: DEFB 0
IteradorVertical: DEFB 0

; PRESUPONE QUE EL TAMAÑO ES DE 8X8
; PARAMETROS:
; memoria: posicion_x
; memoria: posicion_y
;
; MODIFICA REGISTROS: A[X] B[X], C[X], D[X], E[X], H[X], L[X], IX[ ], IY[ ]
;

PrintSprite8x8At:
;ld bc, posicion_x
ld hl, posicion_x 			; carga el puntero a posicion_x en hl
ld c,(hl) 					; carga el valor de posicion_x en c
ld hl, posicion_y			; carga el puntero a posicion_y en hl
ld b,(hl)					; carga el valor de posicion_y en b
ld a, c 					; tomamos el parámetro X que viene en el registro C y lo guardamos en el registro A
sra c 						; desplazamiento aritmético - no interesa lo que se pierde porque está duplicado en A
sra c 
sra c 
and 7						; Se deja en el registro A solo los 3 bits del offset del valor de X

ld (Offset_X), a			; Guarda en memoria el offset_x que está contenido en A
ld hl, VRAM_ADDRESS			; Prueba en primera linea de pantalla
ld b, 0						; la parte alta del offset va a cero, la parte baja viene en c resultado de hacer 3 desplazamientos a la derecha >>>
ADD HL, bc					; añade al inicio de la memoria de video el offset x del sprite

LD ix, Spritemap8x8 		; carga en IX la direccion del mapa de sprites

LoopPrintSprite8x8At:
ld (IteradorVertical), bc
ld a, (Offset_X)			; carga en A el offset_x
LD d, (ix)					; carga en b el byte de la memoria en la direccion apuntada por ix (los datos del sprite)
ld c, 0						; carga en c 0

ret