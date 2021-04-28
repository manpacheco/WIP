VRAM_ADDRESS EQU 16384
;MAX_OFFSET_X EQU 191
MAX_OFFSET_X EQU 208
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
ld c,(hl) 							; carga el conenido de memoria de la variable posicion_x en el registro C
ld a, c 							; tomamos el parámetro X que viene en el registro C y lo guardamos en el registro A
and 7								; Se dejan en el registro A solo los 3 bits del offset del valor de X
ld (Offset_X), a					; Guarda en memoria el offset_x que está contenido en A

srl c 								; desplazamiento aritmético - no interesa lo que se pierde porque está duplicado en A
srl c 		
srl c

ld hl, posicion_y					; carga el puntero a posicion_y en el registro HL
ld b,(hl)							; carga el valor de posicion_y en el registro B

		



ld hl, VRAM_ADDRESS					; Prueba en primera linea de pantalla
; antes de machacar el registro B habría que añadir al puntero el offset_y necesario
;ld b, 0								; la parte alta del offset va a cero, la parte baja viene en c resultado de hacer 3 desplazamientos a la derecha >>>

ld a, b								; nuevo
srl a
srl a
srl a
and 7								; 00000111
ex af, af'							; nuevo 


ADD HL, bc							; añade al inicio de la memoria de video el offset x del sprite
		
LD ix, Spritemap8x8 				; carga en IX la direccion del mapa de sprites
LD b, 8								; carga en B las 8 iteraciones del tamaño vertical
		
		
		
LoopPrintSprite8x8At:		
ld (IteradorVertical), bc		
ld a, (Offset_X)					; carga en A el offset_x
LD d, (ix)							; carga en b el byte de la memoria en la direccion apuntada por ix (los datos del sprite)
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
ld A, E								; Carga en A el registro E, supuestamente con el valor x de la primera columna del marcador
cp L								; Compara el registro A con el registro L (A-L)
jr nz, PrintSprite8x8AtContinuar	; Si no es Z habría que saltar y continuar como si nada
ld a, c								; Si era el caso límite salvamos el registro C en el registro A ...
push hl								; Ponemos a salvo el registro HL
ld L,0								; Ponemos a 0 el registro L para pintar al principio de la pantalla
LD (HL), c							; Cargamos en la dirección apuntada por HL, teóricamente el byte de la derecha del sprite
pop hl								; Restauramos el valor que tenía antes el registro HL
jp PrintSprite8x8AtContinuarDesdeRama
		
PrintSprite8x8AtContinuar:
LD (HL), c							; carga en la dirección apuntada por HL, teóricamente el byte de la derecha del sprite
PrintSprite8x8AtContinuarDesdeRama:
ex af, af'							; restaura A al valor que tenía
DEC L								; deja L como estaba
INC H								; incrementa H, que significa pasar al siguiente scanline
INC ix								; incrementa ix, que significa pasar a la siguiente línea del sprite
ld bc, (IteradorVertical)			; carga en b el iterador vertical
DJNZ LoopPrintSprite8x8At 			; Decreases B and jumps to a label if not zero
	
ret	

;########################################################################################################
;################################### printScoreboard ####################################################
;########################################################################################################
printScoreboard:	
	
ld hl, START_ATTRIBUTE_DATA						; carga en hl el puntero a la zona de los atributos en la zona de RAM de la pantalla
ld b, 0 										; índice de columna - empieza a 0
		
printScoreIterateRows:	

call insertaPrimeraColumnaMarcadorEnRegistroE
ld a, MAX_COLUMN_NUMBER							; carga en el registro A el valor x máximo de toda la pantalla (en caracteres)
ld d,0											; carga 0 en d para que en los 16 bits de DE esté la coordenada X del primer bloque de la zona de marcador
add hl, de										; al puntero a la zona de los atributos le añades la coordenada X para apuntar a la zona del marcador
					
printScoreboardLoop:					
ld (hl), 40										; carga 40 (papel cyan) en la dirección de memoria apuntada por HL
inc e											; incrementa el contador
inc l											; incrementa la parte baja del puntero
call z, IncrementRegisterH						; si se pone a cero llamar a incrementar H (como si fuera un carry)
cp e											; compara el contador con el registro A que contendrá MAX_COLUMN_NUMBER
jr nc, printScoreboardLoop						; si no se ha sobrepasado MAX_COLUMN_NUMBER entonces salta al buc
				
ld a, MAX_ROW_NUMBER							; carga en el registro A el valor y máximo de las filas de la pantalla (en caracteres)
inc b											; incrementa el contador de filas
cp b											; compara el contador con el máximo
jr NC, printScoreIterateRows					; si no se ha sobrepasado, entonce salta de nuevo al bucle
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