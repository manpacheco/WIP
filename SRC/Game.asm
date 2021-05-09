posicion_x: db 0
posicion_y: db 0
inercia_x: db INERCIA_NEUTRAL
inercia_y: db INERCIA_NEUTRAL
estado_sprite: db 0

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

MoveShip_X:
;push hl
;push af
;push bc

ld hl, inercia_x 								; carga en el registro HL el puntero a la variable inercia_x
ld a, (hl)										; carga el contenido de la variable inercia_x en el registro A
cp INERCIA_NEUTRAL
ret z

jr C, MoveShip_X_inercia_negativa				; si hay carry (la inercia es menor que la neutral) salta a negativa
jr NZ, MoveShip_X_inercia_positiva
;si no: inercia neutra

MoveShip_X_inercia_negativa:
ld hl, posicion_x 								; carga en el registro HL el puntero a la variable posicion_x
ld b, (hl) 										; carga el contenido de la variable posicion_x en el registro B
add a, b
sub INERCIA_NEUTRAL
jr NC, MoveShip_fin
add a, MAX_OFFSET_X
jr MoveShip_fin

MoveShip_X_inercia_positiva:
ld hl, posicion_x 								; carga en el registro HL el puntero a la variable posicion_x
ld b, (hl) 										; carga el contenido de la variable posicion_x en el registro B
add a, b
sub INERCIA_NEUTRAL
jr NC, MoveShip_fin
sub MAX_OFFSET_X
jr MoveShip_fin

MoveShip_fin:
ld (hl), a										; carga en la variable apuntada por HL que supuestamente debe de ser la posicion_x, el nuevo valor que está en A
;pop bc
;pop af
;pop hl
ret

;Rota la nave a la derecha
RotateRight:
ld hl, estado_sprite
ld a, (hl)
inc a
ld b, TOTAL_NUMBER_ROTATIONS
cp b
jr nz, RotateRightContinue 
xor a
RotateRightContinue:
ld (hl), a
ret

;Rota la nave a la izquierda
RotateLeft:
ld hl, estado_sprite
ld a, (hl)
cp 0
jr nz, RotateLeftContinue 
ld a, TOTAL_NUMBER_ROTATIONS
RotateLeftContinue:
dec a
ld (hl), a
ret