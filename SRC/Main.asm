org $8000

Main:
ld a, 7 ; selecciona tinta 7 + paper 0*8
ld (23693),a
call 3503

ld a,1 ; 1 is the code for blue
out (254),a
ld a,128
ld (posicion_x),a
xor a
ld (posicion_y),a


;ld bc, $0009 ; 


MainLoop:
call PrintSprite8x8At
call ScanAllKeys
jr MainLoop

ret

include "Game.asm"
include "Video.asm"
include "Sprite.asm"
include "Controls.asm"

end Main

; ojo: OFFSET_X no es lo mismo que posicion_x
; NOTA: al llegar a posicion_x = 16+ sale por otra scanline :O