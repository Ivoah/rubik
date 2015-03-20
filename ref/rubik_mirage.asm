#include	"ti83plus.inc"
#include	"mirage.inc"
	.org	$9d93	
	.db	$BB,$6D
	ret		
	.db	1	
	.db	%11100000,%00000001		;icon
	.db	%11001111,%11111101
	.db	%10011011,%01101101
	.db	%00101101,%10110101
	.db	%01111111,%11111101
	.db	%01001001,%00101101
	.db	%01001001,%00110101
	.db	%01111111,%11111101
	.db	%01001111,%00101101
	.db	%01001111,%00110101
	.db	%01111111,%11111101
	.db	%01111001,%00101001
	.db	%01111001,%00110011
	.db	%01111111,%11100111
	.db	%00000000,%00001111
Description:
	.db	"Rubik", $27, "s Cube for MirageOS",0

MainLoop:

	bcall(_GrBufClr)

	set bufferOnly, (iy+plotFlag3)

	ld hl, RubikLines
	ld b, 21

SkeletonLoop:	
	push bc
	ld b, (hl)
	inc hl
	ld c, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)
	inc hl
	push hl
	bcall(_DarkLine)
	pop hl
	pop bc
	djnz SkeletonLoop

	ld b, 27
	ld hl, DisplayedSquares

DrawColorsLoop:		
	push bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl	
	push hl	

	push de
	
	xor a

	ld c, b
	ld b, a

	ld hl, CubePosition+27
	sbc hl, bc

	ld a, (hl)

	ld hl, Colors
	call AddAToHL

	ld de, saferam1

	ld bc, 8
	ldir
	ld hl, saferam1
	ld bc, 32
	ldir


	pop hl
	push hl

	inc hl
	inc hl
	ld a, (hl)
	add a, a
	ld b, a
	inc hl
	ld de, saferam1
MaskPatternLoop:
	ld a, (de)
	and (hl)
	ld (de), a
	inc de
	inc hl
	djnz MaskPatternLoop

	pop hl

	ld e, (hl)
	inc hl
	ld a, (hl)
	inc hl
	ld b, (hl)
	ld c, 2
	ld l, e
	ld ix, saferam1

	call ilsprite

	pop hl
	pop bc
	djnz DrawColorsLoop

	call ifastcopy

	ld b, 10
	call delayb
	
	ld d, 0			;d contains the two previous keypresses
					;$37 means 3 and 7 were pressed

	ld hl, MainLoop
	push hl			;so 'ret' retuns to MainLoop

KeyLoop:
	halt

	ld a, %11111110		;arrow key group
	call directin
	rra
	jr nc, DownPressed
	rra
	jr nc, LeftPressed
	rra
	jr nc, RightPressed
	rra
	jr nc, UpPressed

	ld a, %11111011		;3,6,9 keys
	call directin
	rra

	rra
	jp nc, Three
	rra
	jp nc, Six
	rra
	jp nc, Nine

	ld a, %11110111		;2,5,8 keys
	call directin
	rra

	rra
	jp nc, Two
	rra
	jp nc, Five
	rra
	jp nc, Eight

	ld a, %11101111		;1,4,7 keys
	call directin
	bit 7, a			;X,T,theta,n (scramble)
	jp z, ScrambleCube
	rra

	rra
	jp nc, One
	rra
	jp nc, Four
	rra
	jp nc, Seven

	ld a, %10111111		;mode key group
	call directin
	bit 6, a
	jp z, ResetCube

	ld a, %11111101		;clear key group
	call directin

	bit 6, a			;check for clear
	jr nz, KeyLoop

	pop hl
	ret

UpPressed:
	call DoCol1Down
	call DoCol2Down
	jp DoCol3Down

RightPressed:
	call DoRow1Left
	call DoRow2Left
	jp DoRow3Left

LeftPressed:
	call DoRow1Right
	call DoRow2Right
	jp DoRow3Right	

DownPressed:
	call DoCol1Up
	call DoCol2Up
	jp DoCol3Up

One:
	ld a, d
	cp $74
	jp z, DoCol1Down	;741
	cp $32
	jp z, DoRow3Left	;321
	ld b, 1
	jr SaveKey

Two:
	ld a, d
	cp $85
	jp z, DoCol2Down	;852
	ld b, 2
	jr SaveKey

Three:
	ld a, d
	cp $96
	jp z, DoCol3Down	;963
	cp $12
	jp z, DoRow3Right	;123
	ld b, 3
	jr SaveKey

Four:
	ld a, d
	cp $65
	jp z, DoRow2Left	;654
	ld b, 4
	jr SaveKey

Five:
	ld a, d
	ld b, 5
	jr SaveKey

Six:
	ld a, d
	cp $45
	jp z, DoRow2Right	;456
	ld b, 6
	jr SaveKey

Seven:
	ld a, d
	cp $14
	jp z, DoCol1Up	;147
	cp $98
	jp z, DoRow1Left	;987
	ld b, 7
	jr SaveKey

Eight:
	ld a, d
	cp $25
	jp z, DoCol2Up	;258
	ld b, 8
	jr SaveKey

Nine:
	ld a, d
	cp $78
	jp z, DoRow1Right	;789
	cp $36
	jp z, DoCol3Up	;369
	ld b, 9

SaveKey:
	and $0f
	cp b
	jr z, SameKey

	ld d, a

	add a, a
	add a, a
	add a, a
	add a, a

	add a, b
	ld d, a
SameKey:
	jp KeyLoop

DoRow1Right:
	ld hl, Row1Left
	call ApplyOperation
	ld hl, Row1Left
	call ApplyOperation
DoRow1Left:
	ld hl, Row1Left
	jr ApplyOperation

DoRow2Left:
	ld hl, Row2Right
	call ApplyOperation
	ld hl, Row2Right
	call ApplyOperation
DoRow2Right:
	ld hl, Row2Right
	jr ApplyOperation

DoRow3Right:
	ld hl, Row3Left
	call ApplyOperation
	ld hl, Row3Left
	call ApplyOperation
DoRow3Left:
	ld hl, Row3Left
	jr ApplyOperation

DoCol1Down:
	ld hl, Col1Up
	call ApplyOperation
	ld hl, Col1Up
	call ApplyOperation
DoCol1Up:
	ld hl, Col1Up
	jr ApplyOperation

DoCol2Up:
	ld hl, Col2Down
	call ApplyOperation
	ld hl, Col2Down
	call ApplyOperation
DoCol2Down:
	ld hl, Col2Down
	jr ApplyOperation

DoCol3Down:
	ld hl, Col3Up
	call ApplyOperation
	ld hl, Col3Up
	call ApplyOperation
DoCol3Up:
	ld hl, Col3Up

ApplyOperation:
	;hl -> operation to be applied
	push hl

	ld hl, CubePosition
	ld de, saferam1
	ld bc, 54
	ldir

	pop hl
	
	ld b, 55
	ld de, CubePosition

OperationLoop:
	ld a, (hl)
	push hl
	ld hl, saferam1-1
	call AddAToHL
	ldi
	pop hl
	inc hl
	djnz OperationLoop
	ret

ResetCube:
	ld b, 0
HoldKeyLoop1:
	halt
	ld a, %10111111		;still mode key group
	call directin
	bit 6, a
	jp nz, KeyLoop
	djnz HoldKeyLoop1

	ld hl, ResetPosition
	ld de, CubePosition
	ld bc, 54
	ldir
	ret

ScrambleCube:
	ld b, 0
HoldKeyLoop2:
	halt
	ld a, %11101111		;X,T,theta,n key group
	call directin
	bit 7, a
	jp nz, KeyLoop
	djnz HoldKeyLoop2

	ld b, 0
ScrambleCubeLoop:
	push bc
	call DoRandomMove
	pop bc
	djnz ScrambleCubeLoop
	ret


DoRandomMove:

	ld b, 12
	call irandom
	add a, a

	ld hl, ScrambleVectorTable
	call AddAToHL

	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a

	jp (hl)

ScrambleVectorTable:
	.dw DoRow1Left
	.dw DoRow1Right
	.dw DoRow2Left
	.dw DoRow2Right
	.dw DoRow3Left
	.dw DoRow3Right
	.dw DoCol1Up
	.dw DoCol1Down
	.dw DoCol2Up
	.dw DoCol2Down
	.dw DoCol3Up
	.dw DoCol3Down

AddAToHL:
	add a, l
	ld l, a
	ret nc
	inc h
	ret


Colors:
	.db	%00000000, %00000000
	.db	%00000000, %00000000
	.db	%00000000, %00000000
	.db	%00000000, %00000000

	.db	%00000000, %00000000
	.db	%01010101, %01010101
	.db	%00000000, %00000000
	.db	%01000100, %01000100

	.db	%10001000, %10001000
	.db	%01010101, %01010101
	.db	%00100010, %00100010
	.db	%01010101, %01010101

	.db	%10101010, %10101010
	.db	%01010101, %01010101
	.db	%10101010, %10101010
	.db	%01010101, %01010101

	.db	%11101110, %11101110
	.db	%01010101, %01010101
	.db	%11111111, %11111111
	.db	%01010101, %01010101

	.db	%11101110, %11101110
	.db	%11111111, %11111111
	.db	%10101010, %10101010
	.db	%11111111, %11111111

CubePosition:
	.db	8,8,8,8,8,8,8,8,8
	.db	24,24,24,24,24,24,24,24,24
	.db	40,40,40,40,40,40,40,40,40
	.db	16,16,16,16,16,16,16,16,16
	.db	32,32,32,32,32,32,32,32,32
	.db	0,0,0,0,0,0,0,0,0

ResetPosition:
	.db	8,8,8,8,8,8,8,8,8
	.db	24,24,24,24,24,24,24,24,24
	.db	40,40,40,40,40,40,40,40,40
	.db	16,16,16,16,16,16,16,16,16
	.db	32,32,32,32,32,32,32,32,32
	.db	0,0,0,0,0,0,0,0,0

; cube operations!

Row1Left:
	.db	19,20,21,4,5,6,7,8,9
	.db	16,13,10,17,14,11,18,15,12
	.db	46,47,48,22,23,24,25,26,27
	.db	28,29,30,31,32,33,34,35,36
	.db	37,38,1,40,41,2,43,44,3
	.db	39,42,45,49,50,51,52,53,54
Row2Right:
	.db	1,2,3,38,41,44,7,8,9
	.db	10,11,12,13,14,15,16,17,18
	.db	19,20,21,4,5,6,25,26,27
	.db	28,29,30,31,32,33,34,35,36
	.db	37,49,39,40,50,42,43,51,45
	.db	46,47,48,22,23,24,52,53,54
Row3Left:
	.db	1,2,3,4,5,6,25,26,27
	.db	10,11,12,13,14,15,16,17,18
	.db	19,20,21,22,23,24,52,53,54
	.db	30,33,36,29,32,35,28,31,34
	.db	7,38,39,8,41,42,9,44,45
	.db	46,47,48,49,50,51,37,40,43

Col1Up:
	.db	28,2,3,31,5,6,34,8,9
	.db	1,11,12,4,14,15,7,17,18
	.db	19,20,21,22,23,24,25,26,27
	.db	54,29,30,51,32,33,48,35,36
	.db	39,42,45,38,41,44,37,40,43
	.db	46,47,16,49,50,13,52,53,10
Col2Down:
	.db	1,11,3,4,14,6,7,17,9
	.db	10,53,12,13,50,15,16,47,18
	.db	19,20,21,22,23,24,25,26,27
	.db	28,2,30,31,5,33,34,8,36
	.db	37,38,39,40,41,42,43,44,45
	.db	46,35,48,49,32,51,52,29,54
Col3Up:
	.db	1,2,30,4,5,33,7,8,36
	.db	10,11,3,13,14,6,16,17,9
	.db	25,22,19,26,23,20,27,24,21
	.db	28,29,52,31,32,49,34,35,46
	.db	37,38,39,40,41,42,43,44,45
	.db	18,47,48,15,50,51,12,53,54

DisplayedSquares:
	.dw Front11, Front12, Front13
	.dw Front21, Front22, Front23
	.dw Front31, Front32, Front33

	.dw Top11, Top12, Top13
	.dw Top21, Top22, Top23
	.dw Top31, Top32, Top33

	.dw Side11, Side12, Side13
	.dw Side21, Side22, Side23
	.dw Side31, Side32, Side33


Front11:
	.db 10,18
	.db 16
	.db %11111000, %00000000
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %00000111, %11111110

Front12:
	.db 11,33
	.db 17
	.db %11000000, %00000000
	.db %11111111, %11111100
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %01111111, %11111110
	.db %00000000, %01111110

Front13:
	.db 13,49
	.db 17
	.db %11111111, %11000000
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %00111111, %11111111
	.db %00000000, %00001111

Front21:
	.db 26,19
	.db 16
	.db %11110000, %00000000
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %00001111, %11111100
	.db %00000000, %00011100

Front22:
	.db 28,34
	.db 16
	.db %11111111, %00000000
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %11111111, %11111100
	.db %00001111, %11111100
	.db %00000000, %00011100

Front23:
	.db 29,49
	.db 17
	.db %11000000, %00000000
	.db %11111111, %11110000
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %00011111, %11111110
	.db %00000000, %00011110

Front31:
	.db 41,20
	.db 15
	.db %11100000, %00000000
	.db %11111111, %11000000
	.db %11111111, %11111000
	.db %11111111, %11111000
	.db %11111111, %11111000
	.db %11111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %00011111, %11111100
	.db %00000000, %01111100

Front32:
	.db 43,34
	.db 16
	.db %11110000, %00000000
	.db %11111111, %11100000
	.db %11111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %01111111, %11111100
	.db %00000011, %11111100
	.db %00000000, %00011100

Front33:
	.db 45,49
	.db 17
	.db %11100000, %00000000
	.db %11111111, %11100000
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %11111111, %11111110
	.db %00111111, %11111110
	.db %00000001, %11111110
	.db %00000000, %00000110

Top11:
	.db 3,34
	.db 2
	.db %11111111, %11100000
	.db %00011111, %11000000

Top12:
	.db 4,46
	.db 2
	.db %11111111, %11111000
	.db %00000111, %11110000

Top13:
	.db 4,59
	.db 3
	.db %00111100, %00000000
	.db %11111111, %11111110
	.db %00000011, %11111100

Top21:
	.db 5,26
	.db 3
	.db %00011111, %11100000
	.db %11111111, %11111100
	.db %00000000, %00110000

Top22:
	.db 6,40
	.db 2
	.db %00111111, %11100000
	.db %11111111, %11111110

Top23:
	.db 7,57
	.db 2
	.db %11111111, %00000000
	.db %01111111, %11111000

Top31:
	.db 7,21
	.db 3
	.db %00010000, %00000000
	.db %11111111, %11111110
	.db %00111111, %11111000

Top32:
	.db 9,35
	.db 3
	.db %01111111, %11111111
	.db %11111111, %11111111
	.db %00000000, %00001110

Top33:
	.db 9,51
	.db 4
	.db %00011110, %00000000
	.db %00111111, %11111111
	.db %11111111, %11111111
	.db %00000000, %11111110

Side11:
	.db 11,66
	.db 18
	.db %00100000, %00000000
	.db %01100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000

Side12:
	.db 9,70
	.db 15
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000

Side13:
	.db 6,73
	.db 14
	.db %01000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000

Side21:
	.db 28,65
	.db 18
	.db %00010000, %00000000
	.db %00110000, %00000000
	.db %01110000, %00000000
	.db %01110000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

Side22:
	.db 24,69
	.db 16
	.db %00100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01100000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

Side23:
	.db 20,72
	.db 15
	.db %00100000, %00000000
	.db %00100000, %00000000
	.db %01100000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %01000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

Side31:
	.db 44,65
	.db 15
	.db %00100000, %00000000
	.db %00100000, %00000000
	.db %01100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11100000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

Side32:
	.db 40,69
	.db 11
	.db %01000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

Side33:
	.db 35,72
	.db 10
	.db %01000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %11000000, %00000000
	.db %10000000, %00000000
	.db %10000000, %00000000

RubikLines:
	.db 17,54,20,9
	.db 32,53,34,6
	.db 48,51,48,4
	.db 65,50,64,1
	.db 69,54,68,9
	.db 72,56,71,15
	.db 75,59,74,21

	.db 34,61,75,59
	.db 30,59,72,56
	.db 25,56,68,54
	.db 17,54,64,50
	.db 18,38,65,33
	.db 19,23,63,17
	.db 20,9,64,1

	.db 17,54,35,61
	.db 32,53,47,60
	.db 49,51,61,60
	.db 65,50,75,59
	.db 65,33,75,45
	.db 65,17,74,31
	.db 64,1,74,22


.end