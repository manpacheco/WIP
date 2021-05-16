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

LD A, 2                 ; Open Channel 2 (Screen) without clearing
CALL ROM_OPEN_CHANNEL
ld c, ixl
inc ixl
LD A, AT                ; AT control character
RST 0x10
LD A, 3                 ; Y
RST 0x10
LD A, 26                ; X
add a, c
RST 0x10
LD A, INK               ; Ink colour
RST 0x10
LD A, 6                ; White
RST 0x10
ld a, b
RST 0x10                ; Print the character
RET

Print_number:

ld ix, 0
ld b, ASCII_CARACTER_4
call Print_ASCII
ld b, ASCII_CARACTER_8
call Print_ASCII
ld b, ASCII_CARACTER_6
call Print_ASCII
ret

; Recibe el número en A (1 byte)
; Devuelve los caracteres en la pila, saldrá primero las unidades luego las decenas y luego las centenas
; Si se implementa Binary_word_to_ASCII podrían ir en BC DE HL

;;;;;;;;;;Binary_byte_to_ASCII:
;;;;;;;;;;
;;;;;;;;;;cp 200
;;;;;;;;;;jr C, Binary_byte_to_ASCII_compara_100 ;el número es menor a 200
;;;;;;;;;;ld b, ASCII_CARACTER_2
;;;;;;;;;;sub 200
;;;;;;;;;;jr Binary_byte_to_ASCII_paso_2
;;;;;;;;;;
;;;;;;;;;;Binary_byte_to_ASCII_compara_100:
;;;;;;;;;;
;;;;;;;;;;cp 100
;;;;;;;;;;jr C, Binary_byte_to_ASCII_compara_fin ;el número es menor a 100
;;;;;;;;;;ld b, ASCII_CARACTER_1
;;;;;;;;;;sub 100
;;;;;;;;;;jr Binary_byte_to_ASCII_paso_2
;;;;;;;;;;
;;;;;;;;;;Binary_byte_to_ASCII_compara_fin:
;;;;;;;;;;
;;;;;;;;;;ld b, ASCII_CARACTER_0
;;;;;;;;;;
;;;;;;;;;;Binary_byte_to_ASCII_paso_2:
;;;;;;;;;;push bc
;;;;;;;;;;ld b, 9
;;;;;;;;;;ld c, ASCII_CARACTER_9
;;;;;;;;;;ld d, 90
;;;;;;;;;;Binary_byte_to_ASCII_paso_2_loop:
;;;;;;;;;;cp d
;;;;;;;;;;jr NC, Binary_byte_to_ASCII_decenas_encontrado ;el número es menor a 200
;;;;;;;;;;dec b
;;;;;;;;;;dec c
;;;;;;;;;;
;;;;;;;;;;ld a, d
;;;;;;;;;;sub 10
;;;;;;;;;;ld d, a
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;djnz Binary_byte_to_ASCII_paso_2_loop
;;;;;;;;;;ld c, ASCII_CARACTER_0
;;;;;;;;;;ld d, 0
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;Binary_byte_to_ASCII_decenas_encontrado:
;;;;;;;;;;sub d
;;;;;;;;;;exx
;;;;;;;;;;
;;;;;;;;;;jr Binary_byte_to_ASCII_paso_3
;;;;;;;;;;
;;;;;;;;;;Binary_byte_to_ASCII_paso_3:
