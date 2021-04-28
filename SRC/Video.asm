VRAM_ADDRESS EQU 16384
MAX_OFFSET_X EQU 191
MAX_COLUMN_NUMBER EQU 31
MAX_ROW_NUMBER EQU 23
START_ATTRIBUTE_DATA EQU 22528


; PRESUPONE QUE EL TAMAÑO ES DE 8X8
; PARAMETROS:
; memoria: posicion_x
; memoria: posicion_y
;
; MODIFICA REGISTROS: A[X] B[X], C[X], D[X], E[X], H[X], L[X], IX[ ], IY[ ]
;

;########################################################################################################
;################################### PrintSprite8x8At ###################################################
;########################################################################################################
PrintSprite8x8At:
call insertaPrimeraColumnaMarcadorEnRegistroE

ld hl, (posicion_x) 				; carga el puntero a posicion_x en hl
ld a, MAX_OFFSET_X	
cp l 								; a-l = MAX_OFFSET_X - posicion x = 175 -180
JP NC, Max_Offset_x_Adjusted	
ld h, a	
ld a, l	
sub h 								; A=A-h 
ld (posicion_x),a	
	
Max_Offset_x_Adjusted:	
ld hl, posicion_x 					; carga de nuevo el puntero a posicion_x en HL
ld c,(hl) 							; carga el contenido de memoria de la variable posicion_x en el registro C
ld a, c 							; tomamos el parámetro X que viene en el registro C y lo guardamos en el registro A
and 7								; Se dejan en el registro A solo los 3 bits del offset del valor de X
ld (Offset_X), a					; Guarda en memoria en la variable offset_x el valor de lo que está contenido en A

srl c 								; desplazamiento aritmético - no interesa lo que se pierde porque está duplicado en A
srl c 		
srl c 		

ld hl, posicion_y					; carga el puntero a posicion_y en el registro HL
ld b,(hl)							; carga el valor de posicion_y en el registro B
ld hl, VRAM_ADDRESS					; Prueba en primera linea de pantalla
;ld b, 0								; la parte alta del offset va a cero, la parte baja viene en c resultado de hacer 3 desplazamientos a la derecha >>>


;; NUEVO START
; antes de machacar el registro B habría que añadir al puntero el offset_y necesario
;ld b, 0								; la parte alta del offset va a cero, la parte baja viene en c resultado de hacer 3 desplazamientos a la derecha >>>

; primero a por la parte NNN
ld a, b								; 
srl a
srl a
srl a
ld d, a
and 7								; 00000111
ex af, af'							; en a´ está la parte nnn
ld a, d
and 24								; 00011000
;or 64								; 01000000 el 010 de cabecera se añade luego
ld d, a								; guarda en el registro D el registro A que tiene el tercio 
ld a, b								; guarda en el registro A el registro B
and 7								; 00000111 -> el registro A está formado por 0000 0SSS
or d								; el registro A está formado por 010T TSSS
ld b, a								; se copia el registro A al B para sumar luego BC a HL

;En C ya viene la columna de la manera 000C CCCC
ex af, af'
or c
ld c, a
;; NUEVO FIN

ADD HL, BC							; añade al inicio de la memoria de video el offset x del sprite
		
LD ix, Spritemap8x8 				; carga en IX la direccion del mapa de sprites
LD b, 8								; carga en B las 8 iteraciones del tamaño vertical
		
		
		
LoopPrintSprite8x8At:		
ld (IteradorVertical), bc		
ld a, (Offset_X)					; carga en A el offset_x
LD d, (ix)							; carga en d el byte de la memoria en la direccion apuntada por ix (los datos del sprite)
ld c, 0								; carga en c 0
		
LoopPrintSprite8x8AtOffset:		
		
;out (254),a						; colorea borde color a
CP $0								; compara a con 0
JR Z, OffsetTerminado				; si es 0 salta a offset terminado
dec a								; si no se ha terminado, decrementa el contador a
SRL d 								; shift 16 bits
RR c								; shift 16 bits
JR LoopPrintSprite8x8AtOffset

OffsetTerminado:

LD (HL), d							; carga en la dirección apuntada por HL, teóricamente el byte de la izquierda del sprite
INC L								; incrementa la columna
	
ex af, af'							; Almacena el registro A en registro sombra A´
ld A, E 							; Carga en A el registro E, supuestamente con el valor x de la primera columna del marcador
sub L								; Compara el registro A con el registro L (A-L)
and 31 								; 00011111
jr nz, PrintSprite8x8AtContinuar	; Si no es Z habría que saltar y continuar como si nada
ld a, c								; Si era el caso límite salvamos el registro C en el registro A ...
push hl								; Ponemos a salvo el registro HL
push af
ld a, l
and 224 							;11100000 - se queda solo con el componente X y descarta el resto
ld l,a
pop af
LD (HL), c							; Cargamos en la dirección apuntada por HL, teóricamente el byte de la derecha del sprite
pop hl								; Restauramos el valor que tenía antes el registro HL
jp PrintSprite8x8AtContinuarDesdeRama
		
PrintSprite8x8AtContinuar:
LD (HL), c							; carga en la dirección apuntada por HL, teóricamente el byte de la derecha del sprite
PrintSprite8x8AtContinuarDesdeRama:
ex af, af'							; restaura A al valor que tenía
DEC L								; deja L como estaba
;INC H								; incrementa H, que significa pasar al siguiente scanline
call NextScan
INC ix								; incrementa ix, que significa pasar a la siguiente línea del sprite
ld bc, (IteradorVertical)			; carga en b el iterador vertical
DJNZ LoopPrintSprite8x8At 			; Decreases B and jumps to a label if not zero
	
ret	



;########################################################################################################
;################################### IncrementRegisterH #################################################
;########################################################################################################
IncrementRegisterH:
inc h
ret

;########################################################################################################
;######################## insertaPrimeraColumnaMarcadorEnRegistroE ######################################
;########################################################################################################
insertaPrimeraColumnaMarcadorEnRegistroE:
ld e, MAX_OFFSET_X				; carga en el registro E el valor x tope de la zona de juego
srl e							; se divide entre 8 para obtener el equivalente en columna
srl e							; se divide entre 8 para obtener el equivalente en columna
srl e							; se divide entre 8 para obtener el equivalente en columna
inc e							; suma 1 al tope de la zona de juego para apuntar al primero de la zona de marcador
ret


; NextScan. https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento
; Obtiene la posición de memoria correspondiente al scanline siguiente al indicado.
; 010T TSSS LLLC CCCC
; Entrada: HL -> scanline actual.
; Salida: HL -> scanline siguiente.
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
NextScan:
inc h ; Incrementa H para incrementar el scanline
ld a, h ; Carga el valor en A
and $07 ; Se queda con los bits del scanline
ret nz ; Si el valor no es 0, fin de la rutina

; Calcula la siguiente línea
ld a, l ; Carga el valor en A
add a, $20 ; Añade 1 a la línea (%0010 0000)
ld l, a ; Carga el valor en L
ret c ; Si hay acarreo, ha cambiado de tercio,

; que ya viene ajustado de arriba. Fin de la rutina

; Si llega aquí, no ha cambiado de tercio y hay que ajustar
; ya que el primer inc h incrementó el tercio
ld a, h ; Carga el valor en A
sub $08 ; Resta un tercio (%0000 1000)
ld h, a ; Carga el valor en H
ret


; ----------------------------------------------------------------------------- 
; PreviousScan. https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento 
; Obtiene la posición de memoria correspondiente al scanline anterior al indicado. 
; 010T TSSS LLLC CCCC 
; Entrada: HL -> scanline actual. 
; Salida: HL -> scanline anterior. 
; Altera el valor de los registros AF, BC y HL. 
; -----------------------------------------------------------------------------
PreviousScan:
ld a, h ; Carga el valor en A
dec h ; Decrementa H para decrementar el scanline
and $07 ; Se queda con los bits del scanline original
ret nz ; Si no estaba en el 0, fin de la rutina 

; Calcula la línea anterior
ld a, l ; Carga el valor de L en A
sub $20 ; Resta una línea
ld l, a ; Carga el valor en L
ret c ; Si hay acarreo, fin de la rutina 

; Si llega aquí, ha pasado al scanline 7 de la línea anterior 
; y ha restado un tercio, que volvemos a sumar 
ld a, h ; Carga el valor de H en A
add a, $08 ; Vuelve a dejar el tercio como estaba
ld h, a ; Carga el valor en h
ret

