VRAM_ADDRESS EQU 16384
MAX_OFFSET_X EQU 192


; PRESUPONE QUE EL TAMAÑO ES DE 8X8
; PARAMETROS:
; memoria: posicion_x
; memoria: posicion_y
;
; MODIFICA REGISTROS: A[X] B[X], C[X], D[X], E[X], H[X], L[X], IX[ ], IY[ ]
;

PrintSprite8x8At:
ld hl, (posicion_x) 			; carga el puntero a posicion_x en hl
ld a, MAX_OFFSET_X
cp l ; a-l = MAX_OFFSET_X - posicion x = 175 -180
JP NC, Max_Offset_x_Adjusted
ld h, a
ld a, l
sub h ; A=A-h = 
ld (posicion_x),a

Max_Offset_x_Adjusted:
ld hl, posicion_x 			; carga de nuevo el puntero a posicion_x en hl
ld c,(hl) 					; carga el valor de posicion_x en c
ld hl, posicion_y			; carga el puntero a posicion_y en hl
ld b,(hl)					; carga el valor de posicion_y en b
ld a, c 					; tomamos el parámetro X que viene en el registro C y lo guardamos en el registro A
srl c 						; desplazamiento aritmético - no interesa lo que se pierde porque está duplicado en A
srl c 
srl c 
and 7						; Se deja en el registro A solo los 3 bits del offset del valor de X

ld (Offset_X), a			; Guarda en memoria el offset_x que está contenido en A
ld hl, VRAM_ADDRESS			; Prueba en primera linea de pantalla
ld b, 0						; la parte alta del offset va a cero, la parte baja viene en c resultado de hacer 3 desplazamientos a la derecha >>>
ADD HL, bc					; añade al inicio de la memoria de video el offset x del sprite

LD ix, Spritemap8x8 		; carga en IX la direccion del mapa de sprites
LD b, 8						; carga en B las 8 iteraciones del tamaño vertical



LoopPrintSprite8x8At:
ld (IteradorVertical), bc
ld a, (Offset_X)			; carga en A el offset_x
LD d, (ix)					; carga en b el byte de la memoria en la direccion apuntada por ix (los datos del sprite)
ld c, 0						; carga en c 0

LoopPrintSprite8x8AtOffset:

;out (254),a				; colorea borde color a
CP $0						; compara a con 0
JR Z, OffsetTerminado		; si es 0 salta a offset terminado
dec a						; si no se ha terminado, decrementa el contador a
SRL d 						; shit 16 bits
RR c						; shift 16 bits
JR LoopPrintSprite8x8AtOffset

OffsetTerminado:

LD (HL), d					; carga en la dirección apuntada por HL, teóricamente el byte de la izquierda del sprite
INC L						; incrementa la columna
LD (HL), c					; carga en la dirección apuntada por HL, teóricamente el byte de la derecha del sprite
DEC L						; deja L como estaba
INC H						; incrementa H, que significa pasar al siguiente scanline
INC ix						; incrementa ix, que significa pasar a la siguiente línea del sprite
ld bc, (IteradorVertical)	; carga en b el iterador vertical
DJNZ LoopPrintSprite8x8At 	; Decreases B and jumps to a label if not zero

ret

