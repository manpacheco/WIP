posicion_x: db 0
posicion_y: db 0

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