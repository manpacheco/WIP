org $8000

Main:
ld a, 7 ; selecciona tinta 7 + paper 0*8
ld (23693),a
call 3503

ld a,1 ; 1 is the code for blue
out (254),a

MainLoop:
;call PrintSprite8x8
ld bc, $0035 ; ejemplo con b=21
call PrintSprite8x8At
call ScanAllKeys
jr MainLoop

ret

include "Video.asm"
include "Sprite.asm"
include "Controls.asm"

end Main