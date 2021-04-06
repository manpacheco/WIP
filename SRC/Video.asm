VRAM_ADDRESS EQU 16384

; PRESUPONE QUE EL TAMAÑO ES DE 8X8
; MODIFICA REGISTROS: A[X] B[X], C[ ], D[X], E[X], H[X], L[X], IX[ ], IY[ ]

PrintSprite8x8:

LD B, 8 ; carga en B las 8 iteraciones
LD HL, VRAM_ADDRESS       ; Prueba en primera linea de pantalla
LD DE, Spritemap8x8 ; carga en DE la direccion del mapa de sprites

LoopPrintSprite8x8:
LD A, (DE) ; carga en a la direccion apuntada por DE
LD (HL), A
INC H
INC de
DJNZ LoopPrintSprite8x8

ret

; PRESUPONE QUE EL TAMAÑO ES DE 8X8
;
; PARAMETROS:
; registro B:posicion Y
; registro C:posicion X

;
; MODIFICA REGISTROS: A[X] B[X], C[X], D[X], E[X], H[X], L[X], IX[ ], IY[ ]
;
PrintSprite8x8At:
ld a, c
sra c ; desplazamiento aritmético - no interesa lo que se pierde
sra c ;
sra c ;
; push b ; EN B VA EL OFFSET DEL SPRITE? 
and 7 ; Se deja en el registro A solo los 3 bits del offset

LD HL, VRAM_ADDRESS       ; Prueba en primera linea de pantalla
;ld bc, 1
ADD HL, bc

LD DE, Spritemap8x8 ; carga en DE la direccion del mapa de sprites

LD B, 8 ; carga en B las 8 iteraciones
LoopPrintSprite8x8At:
LD A, (DE) ; carga en a la direccion apuntada por DE
LD (HL), A
INC H
INC de
DJNZ LoopPrintSprite8x8At

ret