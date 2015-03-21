#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Rubik's Cube",0
corelib_path:
    .db "/lib/core",0
start:

    kld(de, corelib_path)
    pcall(loadLibrary)

    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)

MainLoop:

    pcall(clearBuffer)

    kld(hl, CastleIcon)
    ld de, $0038
    ld b, 8
    pcall(putSpriteOR)

    kld(hl, ThreadsIcon)
    ld de, $5838
    ld b, 8
    pcall(putSpriteOR)

    ld c, 8
    ld a, 96-9
    ld l, 64-8
    pcall(drawVLine)
    
    kld(hl, RubikLines)
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
            ld h, b \ ld l, c
            pcall(drawLine)
        pop hl
    pop bc
    djnz SkeletonLoop

    ld b, 27
    kld(hl, DisplayedSquares)

DrawColorsLoop:     
    push bc
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl  
    push hl

    push bc \ push hl
    kld(bc, 0)
    ex de, hl \ add hl, bc \ ex de, hl ;Mine
    pop hl \ pop bc

    push de
    
    xor a

    ld c, b
    ld b, a

    kld(hl, CubePosition+27)
    sbc hl, bc

    ld a, (hl)

    kld(hl, Colors)
    kcall(AddAToHL)

    kld(de, saferam1)

    ld bc, 8
    ldir
    kld(hl, saferam1)
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
    kld(de, saferam1)
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
    ld d, (hl)
    inc hl
    ld b, (hl)

    push hl
    kld(hl, saferam1)

    pcall(putSprite16OR)
    pop hl

    pop hl
    pop bc
    djnz DrawColorsLoop

    pcall(fastCopy)

    push hl \ ld hl, 500 \ pcall(sleep) \ pop hl
    
    ld d, 0         ;d contains the two previous keypresses
                    ;$37 means 3 and 7 were pressed

    kld(hl, MainLoop)
    push hl         ;so 'ret' retuns to MainLoop

KeyLoop:
    ;halt

    corelib(appGetKey)
    cp kDown
    jr z, DownPressed
    cp kLeft
    jr z, LeftPressed
    cp kRight
    jr z, RightPressed
    cp kUp
    jr z, UpPressed

    cp k3
    kjp(z, Three)
    cp k6
    kjp(z, Six)
    cp k9
    kjp(z, Nine)

    cp k2
    kjp(z, Two)
    cp k5
    kjp(z, Five)
    cp k8
    kjp(z, Eight)

    cp kXTThetaN            ;X,T,theta,n (scramble)
    kjp(z, ScrambleCube)

    cp k1
    kjp(z, One)
    cp k4
    kjp(z, Four)
    cp k7
    kjp(z, Seven)

    cp kMode
    kjp(z, ResetCube)

    cp kClear
    jr nz, KeyLoop

    pop hl
    ret

DownPressed:
    kcall(DoCol1Down)
    kcall(DoCol2Down)
    kjp(DoCol3Down)

LeftPressed:
    kcall(DoRow1Left)
    kcall(DoRow2Left)
    kjp(DoRow3Left)

RightPressed:
    kcall(DoRow1Right)
    kcall(DoRow2Right)
    kjp(DoRow3Right)

UpPressed:
    kcall(DoCol1Up)
    kcall(DoCol2Up)
    kjp(DoCol3Up)

One:
    ld a, d
    cp $74
    kjp(z, DoCol1Down)  ;741
    cp $32
    kjp(z, DoRow3Left)  ;321
    ld b, 1
    kjp(SaveKey)

Two:
    ld a, d
    cp $85
    kjp(z, DoCol2Down)  ;852
    cp $63
    kjp(z, DoRotateClockwise) ;632
    cp $41
    kjp(z, DoRotateCounterClockwise) ;412
    ld b, 2
    jr SaveKey

Three:
    ld a, d
    cp $96
    kjp(z, DoCol3Down)  ;963
    cp $12
    kjp(z, DoRow3Right)  ;123
    ld b, 3
    jr SaveKey

Four:
    ld a, d
    cp $65
    kjp(z, DoRow2Left)  ;654
    cp $21
    kjp(z, DoRotateClockwise) ;214
    cp $87
    kjp(z, DoRotateCounterClockwise) ;874
    ld b, 4
    jr SaveKey

Five:
    ld a, d
    ld b, 5
    jr SaveKey

Six:
    ld a, d
    cp $45
    kjp(z, DoRow2Right)  ;456
    cp $89
    kjp(z, DoRotateClockwise) ;896
    cp $23
    kjp(z, DoRotateCounterClockwise) ;236
    ld b, 6
    jr SaveKey

Seven:
    ld a, d
    cp $14
    kjp(z, DoCol1Up)  ;147
    cp $98
    kjp(z, DoRow1Left)  ;987
    ld b, 7
    jr SaveKey

Eight:
    ld a, d
    cp $25
    kjp(z, DoCol2Up)  ;258
    cp $47
    kjp(z, DoRotateClockwise) ;478
    cp $69
    kjp(z, DoRotateCounterClockwise) ;698
    ld b, 8
    jr SaveKey

Nine:
    ld a, d
    cp $78
    kjp(z, DoRow1Right)  ;789
    cp $36
    kjp(z, DoCol3Up)  ;369
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
    kjp(KeyLoop)

DoRotateClockwise:
    kcall(DoCol1Down)
    kcall(DoCol2Down)
    kcall(DoCol3Down)
    kcall(DoRow3Right)
    kcall(DoCol1Up)
    kcall(DoCol2Up)
    kjp(DoCol3Up)

DoRotateCounterClockwise:
    kcall(DoCol1Down)
    kcall(DoCol2Down)
    kcall(DoCol3Down)
    kcall(DoRow3Left)
    kcall(DoCol1Up)
    kcall(DoCol2Up)
    jr DoCol3Up

DoRow1Right:
    kld(hl, Row1Left)
    kcall(ApplyOperation)
    kld(hl, Row1Left)
    kcall(ApplyOperation)
DoRow1Left:
    kld(hl, Row1Left)
    jr ApplyOperation

DoRow2Left:
    kld(hl, Row2Right)
    kcall(ApplyOperation)
    kld(hl, Row2Right)
    kcall(ApplyOperation)
DoRow2Right:
    kld(hl, Row2Right)
    jr ApplyOperation

DoRow3Right:
    kld(hl, Row3Left)
    kcall(ApplyOperation)
    kld(hl, Row3Left)
    kcall(ApplyOperation)
DoRow3Left:
    kld(hl, Row3Left)
    jr ApplyOperation

DoCol1Down:
    kld(hl, Col1Up)
    kcall(ApplyOperation)
    kld(hl, Col1Up)
    kcall(ApplyOperation)
DoCol1Up:
    kld(hl, Col1Up)
    jr ApplyOperation

DoCol2Up:
    kld(hl, Col2Down)
    kcall(ApplyOperation)
    kld(hl, Col2Down)
    kcall(ApplyOperation)
DoCol2Down:
    kld(hl, Col2Down)
    jr ApplyOperation

DoCol3Down:
    kld(hl, Col3Up)
    kcall(ApplyOperation)
    kld(hl, Col3Up)
    kcall(ApplyOperation)
DoCol3Up:
    kld(hl, Co)l3Up

ApplyOperation:
    ;hl -> operation to be applied
    push hl

    kld(hl, CubePosition)
    kld(de, saferam1)
    ld bc, 54
    ldir

    pop hl
    
    ld b, 55
    kld(de, CubePosition)

OperationLoop:
    ld a, (hl)
    push hl
    kld(hl, saferam1-1)
    kcall(AddAToHL)
    ldi
    pop hl
    inc hl
    djnz OperationLoop
    ret

ResetCube:
    kld(hl, ResetPosition)
    kld(de, CubePosition)
    ld bc, 54
    ldir
    ret

ScrambleCube:
    ld b, 0
ScrambleCubeLoop:
    push bc
    kcall(DoRandomMove)
    pop bc
    djnz ScrambleCubeLoop
    ret


DoRandomMove:

    ld b, 12
    push de
    pcall(getRandom)
    ld d, a
    ld e, b
    pcall(div8By8)
    pop de

    add a, a

    kld(hl, ScrambleVectorTable)
    kcall(AddAToHL)

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    push bc
    kld(bc, 0) \ add hl, bc
    pop bc
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
    .db %00000000, %00000000
    .db %00000000, %00000000
    .db %00000000, %00000000
    .db %00000000, %00000000

    .db %00000000, %00000000
    .db %01010101, %01010101
    .db %00000000, %00000000
    .db %01000100, %01000100

    .db %10001000, %10001000
    .db %01010101, %01010101
    .db %00100010, %00100010
    .db %01010101, %01010101

    .db %10101010, %10101010
    .db %01010101, %01010101
    .db %10101010, %10101010
    .db %01010101, %01010101

    .db %11101110, %11101110
    .db %01010101, %01010101
    .db %11111111, %11111111
    .db %01010101, %01010101

    .db %11101110, %11101110
    .db %11111111, %11111111
    .db %10101010, %10101010
    .db %11111111, %11111111

CubePosition:
    .db 8,8,8,8,8,8,8,8,8
    .db 24,24,24,24,24,24,24,24,24
    .db 40,40,40,40,40,40,40,40,40
    .db 16,16,16,16,16,16,16,16,16
    .db 32,32,32,32,32,32,32,32,32
    .db 0,0,0,0,0,0,0,0,0

ResetPosition:
    .db 8,8,8,8,8,8,8,8,8
    .db 24,24,24,24,24,24,24,24,24
    .db 40,40,40,40,40,40,40,40,40
    .db 16,16,16,16,16,16,16,16,16
    .db 32,32,32,32,32,32,32,32,32
    .db 0,0,0,0,0,0,0,0,0

; cube operations!

Row1Left:
    .db 19,20,21,4,5,6,7,8,9
    .db 16,13,10,17,14,11,18,15,12
    .db 46,47,48,22,23,24,25,26,27
    .db 28,29,30,31,32,33,34,35,36
    .db 37,38,1,40,41,2,43,44,3
    .db 39,42,45,49,50,51,52,53,54
Row2Right:
    .db 1,2,3,38,41,44,7,8,9
    .db 10,11,12,13,14,15,16,17,18
    .db 19,20,21,4,5,6,25,26,27
    .db 28,29,30,31,32,33,34,35,36
    .db 37,49,39,40,50,42,43,51,45
    .db 46,47,48,22,23,24,52,53,54
Row3Left:
    .db 1,2,3,4,5,6,25,26,27
    .db 10,11,12,13,14,15,16,17,18
    .db 19,20,21,22,23,24,52,53,54
    .db 30,33,36,29,32,35,28,31,34
    .db 7,38,39,8,41,42,9,44,45
    .db 46,47,48,49,50,51,37,40,43

Col1Up:
    .db 28,2,3,31,5,6,34,8,9
    .db 1,11,12,4,14,15,7,17,18
    .db 19,20,21,22,23,24,25,26,27
    .db 54,29,30,51,32,33,48,35,36
    .db 39,42,45,38,41,44,37,40,43
    .db 46,47,16,49,50,13,52,53,10
Col2Down:
    .db 1,11,3,4,14,6,7,17,9
    .db 10,53,12,13,50,15,16,47,18
    .db 19,20,21,22,23,24,25,26,27
    .db 28,2,30,31,5,33,34,8,36
    .db 37,38,39,40,41,42,43,44,45
    .db 46,35,48,49,32,51,52,29,54
Col3Up:
    .db 1,2,30,4,5,33,7,8,36
    .db 10,11,3,13,14,6,16,17,9
    .db 25,22,19,26,23,20,27,24,21
    .db 28,29,52,31,32,49,34,35,46
    .db 37,38,39,40,41,42,43,44,45
    .db 18,47,48,15,50,51,12,53,54

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
    .db 17,63-54,20,63-9
    .db 32,63-53,34,63-6
    .db 48,63-51,48,63-4
    .db 65,63-50,64,63-1
    .db 69,63-54,68,63-9
    .db 72,63-56,71,63-15
    .db 75,63-59,74,63-21

    .db 34,63-61,75,63-59
    .db 30,63-59,72,63-56
    .db 25,63-56,68,63-54
    .db 17,63-54,64,63-50
    .db 18,63-38,65,63-33
    .db 19,63-23,63,63-17
    .db 20,63-9,64,63-1

    .db 17,63-54,35,63-61
    .db 32,63-53,47,63-60
    .db 49,63-51,61,63-60
    .db 65,63-50,75,63-59
    .db 65,63-33,75,63-45
    .db 65,63-17,74,63-31
    .db 64,63-1,74,63-22

CastleIcon:
    .db %11111111
    .db %00000001
    .db %01010101
    .db %00000001
    .db %01010101
    .db %00000001
    .db %01010101
    .db %00000001

ThreadsIcon:
    .db %11111111
    .db %00000000
    .db %01011110
    .db %00000000
    .db %01011110
    .db %00000000
    .db %01011110
    .db %00000000

saferam1:
    .fill 256