; ROM routine addresses
ROM_CLS                 EQU  0x0DAF             ; Clears the screen and opens channel 2
ROM_OPEN_CHANNEL        EQU  0x1601             ; Open a channel
ROM_PRINT               EQU  0x203C             ; Print a string 
; PRINT control codes - work with ROM_PRINT and RST 0x10
INK                     EQU 0x10
PAPER                   EQU 0x11
FLASH                   EQU 0x12
BRIGHT                  EQU 0x13
INVERSE                 EQU 0x14
OVER                    EQU 0x15
AT                      EQU 0x16
TAB                     EQU 0x17
CR                      EQU 0x0C
ASCII_CARACTER_0		EQU 48
ASCII_CARACTER_1		EQU 49
ASCII_CARACTER_2		EQU 50
ASCII_CARACTER_3		EQU 51
ASCII_CARACTER_4		EQU 52
ASCII_CARACTER_5		EQU 53
ASCII_CARACTER_6		EQU 54
ASCII_CARACTER_7		EQU 55
ASCII_CARACTER_8		EQU 56
ASCII_CARACTER_9		EQU 57

; Print_ASCII: lee el caracter del registro b y lleva el contador en el registro IX parte baja (IXL)
Print_ASCII:
ld ixh, c
LD A, 2                 ; Open Channel 2 (Screen) without clearing
CALL ROM_OPEN_CHANNEL
ld b, ixl
dec ixl
LD A, AT                ; AT control character
RST 0x10
LD A, 3                 ; Y
RST 0x10
LD A, 28                ; X
add a, b
RST 0x10
LD A, INK               ; Ink colour
RST 0x10
LD A, 6                ; White
RST 0x10
ld a, ixh
RST 0x10                ; Print the character
RET

Print_number:

ld ix, 0
;ld b, ASCII_CARACTER_4
;call Print_ASCII
;ld b, ASCII_CARACTER_8
;call Print_ASCII
;ld b, ASCII_CARACTER_6

ld a, 235
call Byte_to_ASCII

pop bc
call Print_ASCII

pop bc
call Print_ASCII

pop bc
call Print_ASCII

ret

; Recibe el número en A (1 byte)
; Devuelve los caracteres en la pila, saldrá primero las unidades luego las decenas y luego las centenas
Byte_to_ASCII:

Byte_to_ASCII_paso_1:
ld L, ASCII_CARACTER_3							; Se carga el carácter máximo+1 (en las centenas será 2+1=3) en el registro C irán los CARACTERES ASCII
ld H, 300										; se carga el primer posible sustraendo ((200+100) mod 255), en el registro B irán los SUSTRAENDOS
Binary_byte_to_ASCII_paso_1_loop:
ex af,af'										; salvaguarda el registro A en A´
ld a, H											; mete el registro B con el sustraendo en A
sub 100											; se le quitan 100 unidades al sustraendo
ld H, a											; mete el nuevo sustraendo en el registro b
ex af,af'										; restaura el registro A
dec L											; decrementa el caracter ASCII
cp H											; compara el número con el sustraendo
jr NC, Byte_to_ASCII_paso_1_encontrado 			; si el número es mayor o igual a 200, entonces salta a encontrado

ex af,af'										; si el número era menor, resguarda el registro A en A`
ld a, L											; carga el ASCII en el registro A
cp ASCII_CARACTER_0								; Hemos llegado al ASCII_CARACTER_0?
ex af,af'										; restaura registro A
jr nz, Binary_byte_to_ASCII_paso_1_loop			; si no habíamos llegado al ASCII_CARACTER_0 ejecuta otro bucle

Byte_to_ASCII_paso_1_encontrado:
sub h											;se resta al número (en el registro A) el sustraendo (en el registro B)
Byte_to_ASCII_paso_1_fin:


;;; BC->
;;; HL

ex (sp), hl										; primer dígito a la pila (en el registro HL, EN LA PARTE ALTA)
push hl											; se empuja la dirección de retorno en la pila

ld L, ASCII_CARACTER_9+1						; Se carga el carácter máximo+1 (en las decenas será ASCII_CARACTER+1) en el registro C irán los CARACTERES ASCII
Byte_to_ASCII_paso_2:
ld h, 100										; se carga el primer posible sustraendo (100), en el registro B irán los SUSTRAENDOS
Binary_byte_to_ASCII_paso_2_loop:
ex af,af'										; salvaguarda el registro A en A´
ld a, h											; mete el registro B con el sustraendo en A
sub 10											; se le quitan 10 unidades al sustraendo
ld h, a											; mete el nuevo sustraendo en el registro b
ex af,af'										; restaura el registro A
dec L											; decrementa el caracter ASCII
cp h											; compara el número con el sustraendo
jr NC, Byte_to_ASCII_paso_2_encontrado 			; si el número es mayor o igual al sustraendo, entonces salta a encontrado

ex af,af'										; si el número era menor, resguarda el registro A en A`
ld a, L											; carga el ASCII en el registro A
cp ASCII_CARACTER_0								; Hemos llegado al ASCII_CARACTER_0?
ex af,af'										; restaura registro A
jr nz, Binary_byte_to_ASCII_paso_2_loop			; si no habíamos llegado al ASCII_CARACTER_0 ejecuta otro bucle

Byte_to_ASCII_paso_2_encontrado:
sub h											; se resta al número (en el registro A) el sustraendo (en el registro B)
Byte_to_ASCII_paso_2_fin:
ex (sp), hl										; primer dígito a la pila (en el registro HL, EN LA PARTE ALTA)
push hl											; se empuja la dirección de retorno en la pila

;;; BC->
;;; HL

Byte_to_ASCII_paso_3:
ld L, ASCII_CARACTER_9+1						; Se carga el carácter máximo+1 (en las decenas será ASCII_CARACTER+1) en el registro C irán los CARACTERES ASCII
ld H, 10										; se carga el primer posible sustraendo (10), en el registro B irán los SUSTRAENDOS
Binary_byte_to_ASCII_paso_3_loop:
dec H
dec L											; decrementa el caracter ASCII
cp H											; compara el número con el sustraendo
jr NC, Byte_to_ASCII_paso_3_encontrado 			; si el número es mayor o igual al sustraendo, entonces salta a encontrado

ex af,af'										; si el número era menor, resguarda el registro A en A`
ld a, L											; carga el ASCII en el registro A
cp ASCII_CARACTER_0								; Hemos llegado al ASCII_CARACTER_0?
ex af,af'										; restaura registro A
jr nz, Binary_byte_to_ASCII_paso_3_loop			; si no habíamos llegado al ASCII_CARACTER_0 ejecuta otro bucle

Byte_to_ASCII_paso_3_encontrado:
sub H											; se resta al número (en el registro A) el sustraendo (en el registro B)
Byte_to_ASCII_paso_3_fin:
ex (sp), hl										; primer dígito a la pila (en el registro HL, EN LA PARTE ALTA)
push hl											; se empuja la dirección de retorno en la pila

ret

