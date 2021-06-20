TOTAL_NUMBER_ROTATIONS EQU 16
INERCIA_MAX_NEGATIVA_AJUSTADA EQU 0
INERCIA_NEUTRAL_AJUSTADA EQU 4
INERCIA_MAX_POSITIVA_AJUSTADA EQU 8
INERCIA_MAX_NEGATIVA EQU 5
INERCIA_NEUTRAL EQU 64 ; %100000
INERCIA_MAX_POSITIVA EQU 142 ;  %1000 1110
SPRITE_PLANO_HACIA_ARRIBA EQU 0
SPRITE_PLANO_HACIA_DERECHA EQU 4
SPRITE_PLANO_HACIA_ABAJO EQU 8
SPRITE_PLANO_HACIA_IZQUIERDA EQU 12
posicion_x: db 0
posicion_y: db 0
inercia_x: db INERCIA_NEUTRAL
inercia_y: db INERCIA_NEUTRAL
estado_sprite: db 0
;					0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
lista_inercia_x: db 0, 1, 2, 3, 4, 3, 2, 1, 0, 1, 2, 3, 4, 3, 2, 1
lista_inercia_y: db 4, 3, 2, 1, 0, 1, 2, 3, 4, 3, 2, 1, 0, 1, 2, 3


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
;###################################### MoveShip_X ######################################################
;########################################################################################################
MoveShip_X:

ld hl, inercia_x 								; carga en el registro HL el puntero a la variable inercia_x
ld a, (hl)										; carga el contenido de la variable inercia_x en el registro A
srl a
srl a
srl a
srl a
cp INERCIA_NEUTRAL_AJUSTADA
ret z
jr C, MoveShip_X_inercia_negativa				; si hay carry (la inercia es menor que la neutral) salta a negativa
jr NZ, MoveShip_X_inercia_positiva
;si no: inercia neutra

MoveShip_X_inercia_negativa:
ld hl, posicion_x 								; carga en el registro HL el puntero a la variable posicion_x
ld b, (hl) 										; carga el contenido de la variable posicion_x en el registro B
add a, b
sub INERCIA_NEUTRAL_AJUSTADA
jr NC, MoveShip_fin
add a, MAX_OFFSET_X
jr MoveShip_fin

MoveShip_X_inercia_positiva:
ld hl, posicion_x 								; carga en el registro HL el puntero a la variable posicion_x
ld b, (hl) 										; carga el contenido de la variable posicion_x en el registro B
add a, b
sub INERCIA_NEUTRAL_AJUSTADA
jr NC, MoveShip_fin
sub MAX_OFFSET_X
jr MoveShip_fin

MoveShip_fin:
ld (hl), a										; carga en la variable apuntada por HL que supuestamente debe de ser la posicion_x, el nuevo valor que está en A
ret

;########################################################################################################
;###################################### RotateRight #####################################################
;########################################################################################################
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

;########################################################################################################
;###################################### RotateLeft ##############################@#######################
;########################################################################################################
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

;########################################################################################################
;################################### Aumenta_inercia_x ##################################################
;########################################################################################################
; Aumenta la inercia x
; el incremento se espera que venga en el registro B
Aumenta_inercia_x:
ld hl, inercia_x
jr Aumenta_inercia_generica

;########################################################################################################
;################################### Aumenta_inercia_y ##################################################
;########################################################################################################
; Aumenta la inercia Y
; el incremento se espera que venga en el registro B
Aumenta_inercia_y:
ld hl, inercia_y
jr Aumenta_inercia_generica

;########################################################################################################
;############################### Aumenta_inercia_generica ###############################################
;########################################################################################################
; Aumenta la inercia generica
; el incremento se espera que venga en el registro B
Aumenta_inercia_generica:
ld a, (hl)
add a, b
cp INERCIA_MAX_POSITIVA
jr NC, Aumenta_inercia_generica_Ajustar
ld (hl), a
ret
Aumenta_inercia_generica_Ajustar:
ld (hl), INERCIA_MAX_POSITIVA
ret

;########################################################################################################
;################################# Disminuye_inercia_x ##################################################
;########################################################################################################
; Disminuye la inercia X 
; el decremento se espera que venga en el registro B
Disminuye_inercia_x:
ld hl, inercia_x
jr Disminuye_inercia_generica

;########################################################################################################
;################################# Disminuye_inercia_y ##################################################
;########################################################################################################
Disminuye_inercia_y:
ld hl, inercia_y
jr Disminuye_inercia_generica

;########################################################################################################
;############################### Disminuye_inercia_generica #############################################
;########################################################################################################
Disminuye_inercia_generica:
ld a, (hl)
sub b
cp INERCIA_MAX_NEGATIVA
jr C, Disminuye_inercia_generica_Ajustar
ld (hl), a
ret
Disminuye_inercia_generica_Ajustar:
ld (hl), INERCIA_MAX_NEGATIVA
ret
; FIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;########################################################################################################
;################################ Acelera con orientación ###############################################
;########################################################################################################
Acelera:
ld hl, estado_sprite			; carga en hl el puntero a estado_sprite
ld e, (hl)						; carga en el registro E el contenido del registro E, supuestamente la variable estado_sprite
ld d, 0							; carga 0 en el registro D. A aprtir de aquí tenemos el estado en DE, el byte que nos interesa en el registro E
; primero inercia X
Acelera_x:
ld hl, lista_inercia_x			; carga en hl el puntero a lista_inercia_x
add hl, de						; suma la inercia_x y la variable estado para obtener el puntero al offset
ld b, (hl)						; el contenido del offset se carga en el registro B

push af
push bc
push de
push hl
ld a, b
call Print_inc_x_inercia		; depuración - borrar tras probar
pop hl
pop de
pop bc
pop af

ld a, e							; el estado, supuestamente en el registro E, se pasa al registro A para hacer comparación
cp SPRITE_PLANO_HACIA_ARRIBA 	; si está mirando en plano hacia arriba
jr Z, Acelera_y					; no habrá aceleración x, pasa a la aceleración Y
cp SPRITE_PLANO_HACIA_ABAJO 	; si está mirando en plano hacia abajo
jr Z, Acelera_y					; tampoco habrá aceleración x, pasa a la aceleración Y

jr C, Aumenta_inercia_x
jr NC, Disminuir_inercia_x


Aumentar_inercia_x:
call Aumenta_inercia_x		; Si mira hacia la derecha, habrá que aumentar la inercia X
jr Acelera_y

Disminuir_inercia_x:
call NC, Disminuye_inercia_x	; Si mira hacia la izquierda, habrá que disminuir la inercia X
jr Acelera_y

; en segundo lugar inercia Y
Acelera_y:
ld hl, lista_inercia_y			; carga en hl el puntero a lista_inercia_y
add hl, de						; suma la inercia_y y la variable estado para obtener el puntero al offset
ld b, (hl)						; el contenido del offset se carga en el registro B

push af
push bc
push de
push hl
ld a, b
call Print_inc_y_inercia		; depuración - borrar tras probar
pop hl
pop de
pop bc
pop af


ld a, e							; el estado, supuestamente en el registro E, se pasa al registro A para hacer comparación
cp SPRITE_PLANO_HACIA_IZQUIERDA	; si está mirando en plano hacia la izquierda
jr Z, Acelera_end				; no habrá aceleración y, termina
jr NC, Aumenta_inercia_y

cp SPRITE_PLANO_HACIA_DERECHA 	; si está mirando en plano hacia derecha
jr Z, Acelera_end				; tampoco habrá aceleración Y, termina
jr C, Aumenta_inercia_y

jr NC, Disminuir_inercia_y


Aumentar_inercia_y:
call Aumenta_inercia_y		; Si mira hacia la derecha, habrá que aumentar la inercia X
jr Acelera_end

Disminuir_inercia_y:
call NC, Disminuye_inercia_y	; Si mira hacia la izquierda, habrá que disminuir la inercia X
jr Acelera_end

Acelera_end:

ret


; la inercia debe ir en el registro B
;lista_inercia_x
;lista_inercia_x