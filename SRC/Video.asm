VRAM_ADDRESS EQU 16384
MAX_OFFSET_X EQU 191
MAX_OFFSET_Y EQU 191
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
nop
ld hl, $5800
nop
ld (hl), 79
nop

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
ld b, (hl)
ld a, MAX_OFFSET_Y
cp b
JP C, Ajustar_posicion_y
JP Continuar_despues_gestionar_posicion_y
Ajustar_posicion_y:
ld a,2 ; 1 is the code for blue
out (254),a
ld a,b
sub MAX_OFFSET_Y
ld (hl), a
JP Continuar_despues_gestionar_posicion_y



Continuar_despues_gestionar_posicion_y:
ld b,(hl)							; carga el valor de posicion_y en el registro B
ld hl, VRAM_ADDRESS					; Prueba en primera linea de pantalla

ld a, b								; PRIMERA PARTE: la sección NNN, se pasa la posicion Y desde el registro B al registro A
and 56								; 0011 1000
add a,a								; se desplaza a la izquierda (multiplicando x2).
add a,a								; se desplaza a la izquierda (multiplicando x2). El desplazamiento acumulado son 2 bits
ex af, af'							; en el registro A está NNN0 0000 y se pasa al A`


ld a, b								; SEGUNDA PARTE: la sección TT. En el registro D está el valor de la posicion Y dividida entre 8. Se pasa de nuevo al registro A
srl a								; se desplaza a la derecha  
srl a								; se desplaza a la derecha  
srl a								; se desplaza a la derecha
and 24								; 00011000
ld d, a								; guarda en el registro D el registro A que tiene el tercio en formato 000T T000

ld a, b								; guarda en el registro A el registro B que tiene la variable posicion y con el valor inicial sin modificar
and 7								; 00000111 -> el registro A se queda solamante con el scanline de la forma 0000 0SSS
or d								; el registro A está formado por 000T TSSS
ld b, a								; se copia el registro A al B para sumar luego BC a HL

;En C ya viene la columna de la manera 000C CCCC
ex af, af'
or c
ld c, a

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
DEC L								; deja L como estaba

ex af, af'							; restaura A al valor que tenía
push af								; resguarda el registro A
ld a, h								; carga en el registro A la parte alta del puntero a VRAM
cp %01010111						; Compara con la parte alta del tope de suelo
jr z, Continuar_chequeo_suelo		; si no es igual , salta y sigue como si nada
; cp %01000000						; Compara con la parte alta del tope de techo
; jr z, Continuar_chequeo_suelo		; si no es igual , salta y sigue como si nada


Chequeo_terminado:
pop af								; volvemos a restaurar el registro A
call NextScan
INC ix								; incrementa ix, que significa pasar a la siguiente línea del sprite
ld bc, (IteradorVertical)			; carga en b el iterador vertical
DJNZ LoopPrintSprite8x8At 			; Decreases B and jumps to a label if not zero
ret	

Continuar_chequeo_suelo:
ld a, l								; carga el registro L en el registro A
or %00011111						; se establecen a 1 los bits correspondientes al componente X
cp $FF								; compara con la parte baja del tope
jr nz, Chequeo_terminado				; si no es igual, salta y continua como si nada
ld a,l								; si es igual, carga el registro L en el registro A
and %00011111						; efectúa un AND para resetear el valor pero respetando el componente X
ld l, a								; pasa el resultado al registro L
ld h, %01000000						; resetea al mínimo valor de VRAM el registro H
jr Chequeo_terminado				; ya se ha terminado el proceso, salto incondicional y continúa


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