ObjC9:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjC9_Index(pc,d0.w),d1
                jmp     ObjC9_Index(pc,d1.w)
; ===========================================================================
ObjC9_Index:    offsetTable
                offsetTableEntry.w ObjC9_Init           ; 0
                offsetTableEntry.w ObjC9_Main           ; 2
; ===========================================================================

ObjC9_Init:
                addq.b  #2,routine(a0)
                moveq   #0,d0
                move.b  subtype(a0),d0
                lea     (PaletteChangerDataIndex).l,a1
                adda.w  (a1,d0.w),a1
                move.l  (a1)+,ttlscrpalchanger_codeptr(a0)
                movea.l (a1)+,a2
                move.b  (a1)+,d0
                move.w  d0,ttlscrpalchanger_start_offset(a0)
                lea     (Target_palette).w,a3
                adda.w  d0,a3
                move.b  (a1)+,d0
                move.w  d0,ttlscrpalchanger_length(a0)

-               move.w  (a2)+,(a3)+
                dbf     d0,-

                move.b  (a1)+,d0
                move.b  d0,ttlscrpalchanger_fadein_time_left(a0)
                move.b  d0,ttlscrpalchanger_fadein_time(a0)
                move.b  (a1)+,ttlscrpalchanger_fadein_amount(a0)
                rts
; ===========================================================================

ObjC9_Main:
                subq.b  #1,ttlscrpalchanger_fadein_time_left(a0)
                bpl.s   +
                move.b  ttlscrpalchanger_fadein_time(a0),ttlscrpalchanger_fadein_time_left(a0)
                subq.b  #1,ttlscrpalchanger_fadein_amount(a0)
                bmi.w   DeleteObject
                movea.l ttlscrpalchanger_codeptr(a0),a2
                movea.l a0,a3
                move.w  ttlscrpalchanger_length(a0),d0
                move.w  ttlscrpalchanger_start_offset(a0),d1
                lea     (Normal_palette).w,a0
                adda.w  d1,a0
                lea     (Target_palette).w,a1
                adda.w  d1,a1

-               jsr     (a2)                            ; dynamic call! to Pal_FadeFromBlack.UpdateColour, Palette_DecreaseTowardTarget, or Palette_IncreaseTowardWhite, assuming the PaletteChangerData pointers haven't been changed
                dbf     d0,-

                movea.l a3,a0
+
                rts
; ===========================================================================
; off_1337C:
PaletteChangerDataIndex:    offsetTable
                offsetTableEntry.w PaletteTransition_TitleEmblemFromBlack  ; 0
                offsetTableEntry.w PaletteTransition_TitleBackgroundDown  ; 2
                offsetTableEntry.w PaletteTransition_EndingPhotosDown  ; 4
                offsetTableEntry.w PaletteTransition_EndingPhotosToWhite  ; 6
                offsetTableEntry.w PaletteTransition_EndingSonicDown  ; 8
                offsetTableEntry.w PaletteTransition_EndingBackgroundDown  ; $A
                offsetTableEntry.w PaletteTransition_EndingSuperSonicDown  ; $C
                offsetTableEntry.w PaletteTransition_EndingTailsDown  ; $E

C9PalInfo       macro   codeptr,dataptr,loadtoOffset,length,fadeinTime,fadeinAmount
                    dc.l    codeptr, dataptr
                    dc.b    loadtoOffset, length, fadeinTime, fadeinAmount
                endm

PaletteTransition_TitleEmblemFromBlack: C9PalInfo Pal_FadeFromBlack.UpdateColour, Palette_TitleEmblem, $60, $F,2,$15
PaletteTransition_TitleBackgroundDown:  C9PalInfo Palette_DecreaseTowardTarget, Palette_TitleBackground, $40, $F,4,7
PaletteTransition_EndingPhotosDown:     C9PalInfo Palette_DecreaseTowardTarget,  Palette_EndingPhotos,   0, $F,8,7
PaletteTransition_EndingPhotosToWhite:  C9PalInfo Palette_IncreaseTowardWhite,  Palette_EndingPhotos,   0, $F,8,7
PaletteTransition_EndingSonicDown:      C9PalInfo Palette_DecreaseTowardTarget,  Palette_EndingSonic,   0,$1F,4,7
PaletteTransition_EndingBackgroundDown: C9PalInfo Palette_DecreaseTowardTarget,  Palette_EndingBackground, $40,$1F,4,7
PaletteTransition_EndingSuperSonicDown: C9PalInfo Palette_DecreaseTowardTarget,  Palette_EndingSuperSonic,   0, $F,4,7
PaletteTransition_EndingTailsDown:      C9PalInfo Palette_DecreaseTowardTarget,  Palette_EndingTails,   0,$1F,4,7

Palette_TitleSonic:         BINCLUDE "data/art/palettes/Title Sonic.bin"
Palette_TitleBackground:    BINCLUDE "data/art/palettes/Title Background.bin"
Palette_TitleEmblem:        BINCLUDE "data/art/palettes/Title Emblem.bin"

; ===========================================================================

Palette_DecreaseTowardTarget:

                move.b  (a1)+,d2
                andi.b  #$E,d2
                move.b  (a0),d3
                cmp.b   d2,d3
                bls.s   Palette_DecreaseGreenRed
                subq.b  #2,d3
                move.b  d3,(a0)

Palette_DecreaseGreenRed:
                addq.w  #1,a0
                move.b  (a1)+,d2
                move.b  d2,d3
                andi.b  #$E0,d2
                andi.b  #$E,d3
                move.b  (a0),d4
                move.b  d4,d5
                andi.b  #$E0,d4
                andi.b  #$E,d5
                cmp.b   d2,d4
                bls.s   Palette_DecreaseRed
                subi.b  #$20,d4

Palette_DecreaseRed:
                cmp.b   d3,d5
                bls.s   Palette_StoreDecreasedGreenRed
                subq.b  #2,d5

Palette_StoreDecreasedGreenRed:
                or.b    d4,d5
                move.b  d5,(a0)+
                rts
; ===========================================================================

Palette_IncreaseTowardWhite:
                moveq   #$E,d2
                move.b  (a0),d3
                and.b   d2,d3
                cmp.b   d2,d3
                bhs.s   Palette_IncreaseGreenRed
                addq.b  #2,d3
                move.b  d3,(a0)

Palette_IncreaseGreenRed:
                addq.w  #1,a0
                move.b  (a0),d3
                move.b  d3,d4
                andi.b  #$E0,d3
                andi.b  #$E,d4
                cmpi.b  #-$20,d3
                bhs.s   Palette_IncreaseRed
                addi.b  #$20,d3

Palette_IncreaseRed:
                cmp.b   d2,d4
                bhs.s   Palette_StoreIncreasedGreenRed
                addq.b  #2,d4

Palette_StoreIncreasedGreenRed:
                or.b    d3,d4
                move.b  d4,(a0)+
                rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
