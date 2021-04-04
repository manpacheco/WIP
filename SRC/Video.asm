; LA POSICION DE MEMORIA DE VIDEO TIENE QUE IR EN EL REGISTRO A
; PRESUPONE QUE EL TAMAÑO ES DE 8X8
PrintSprite8x8:

LD B, 8 ; carga en B las 8 iteraciones
LD HL, $4000       ; Prueba en primera linea de pantalla
LD DE, Spritemap8x8 ; carga en DE la direccion del mapa de sprites

LoopPrintSprite8x8:
LD A, (DE) ; carga en a la direccion apuntada por DE
LD (HL), A
INC H
INC de
DJNZ LoopPrintSprite8x8

ret