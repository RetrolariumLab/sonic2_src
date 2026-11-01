Obj59:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj59_Index(pc,d0.w),d1
                jmp     Obj59_Index(pc,d1.w)
; ===========================================================================
; off_35FCA:
Obj59_Index:    offsetTable
                offsetTableEntry.w Obj59_Init           ; 0
                offsetTableEntry.w loc_36022            ; 2
                offsetTableEntry.w loc_3533A            ; 4
                offsetTableEntry.w loc_36160            ; 6
                offsetTableEntry.w loc_36172            ; 8
; ===========================================================================
; loc_35FD4:
Obj59_Init:
                st.b    (SS_NoCheckpointMsg_flag).w
                st.b    (SS_Pause_Only_flag).w
                subi_.w #1,objoff_2A(a0)
                cmpi.w  #-$3C,objoff_2A(a0)
                beq.s   +
                rts
; ---------------------------------------------------------------------------
+
                moveq   #0,d0
                move.b  (Current_Special_Stage).w,d0
                bsr.s   SpecialStageMessage_LoadEmeraldColors
                addq.b  #2,routine(a0)
                move.l  #Obj59_MapUnc_3625A,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialEmerald,3,0),art_tile(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #4,priority(a0)
                move.w  #$36,objoff_30(a0)
                move.b  #$40,angle(a0)
                bsr.w   SpecialStageObject_CreateShadow

loc_36022:
                bsr.w   SpecialStageEmerald_UpdateMusicFade
                bsr.w   SpecialStageObject_UpdateDepth
                bsr.w   SpecialStageEmerald_ProjectPosition
                lea     (ChaosEmerald_Animation).l,a1
                bsr.w   SpecialStageObject_AnimateLoop
                jmpto   JmpTo44_DisplaySprite
; ===========================================================================

SpecialStageEmerald_ProjectPosition:
                move.w  d7,-(sp)
                moveq   #0,d2
                moveq   #0,d3
                moveq   #0,d4
                moveq   #0,d5
                moveq   #0,d6
                moveq   #0,d7
                movea.l (SS_CurrentPerspective).w,a1
                adda_.l #2,a1
                move.w  objoff_30(a0),d0
                subq.w  #1,d0
                add.w   d0,d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                move.b  (a1,d0.w),d2
                move.b  1(a1,d0.w),d3
                move.b  2(a1,d0.w),d4
                move.b  3(a1,d0.w),d5
                move.w  d5,d6
                swap    d5
                move.w  d6,d5
                move.w  d4,d6
                swap    d4
                move.w  d6,d4
                bpl.s   loc_36088
                cmpi.b  #$48,d3
                blo.s   loc_36088
                ext.w   d3

loc_36088:
                move.w  d4,d6
                add.w   d4,d4
                add.w   d6,d4
                lsr.w   #2,d4
                move.w  d5,d6
                add.w   d5,d5
                add.w   d6,d5
                lsr.w   #2,d5
                move.b  angle(a0),d0
                jsrto   JmpTo14_CalcSine
                muls.w  d4,d1
                muls.w  d5,d0
                asr.l   #8,d0
                asr.l   #8,d1
                add.w   d2,d1
                add.w   d3,d0
                move.w  d1,x_pos(a0)
                move.w  d0,y_pos(a0)
                move.b  d1,objoff_3A(a0)
                move.b  d0,objoff_3B(a0)
                swap    d4
                swap    d5
                movea.l objoff_34(a0),a1                ; a1=object
                move.b  angle(a0),d0
                jsrto   JmpTo14_CalcSine
                move.w  d4,d6
                lsr.w   #2,d6
                add.w   d6,d4
                muls.w  d4,d1
                move.w  d5,d6
                asr.w   #2,d6
                add.w   d6,d5
                muls.w  d5,d0
                asr.l   #8,d0
                asr.l   #8,d1
                add.w   d2,d1
                add.w   d3,d0
                move.w  d1,x_pos(a1)
                move.w  d0,y_pos(a1)
                move.w  (sp)+,d7
                rts
; ===========================================================================

SpecialStageEmerald_UpdateMusicFade:
                cmpi.b  #3,anim(a0)
                blo.s   ChaosEmerald_Return
                tst.b   objoff_3E(a0)
                bne.s   loc_3610C
                move.w  #MusID_FadeOut,d0
                jsr     (PlayMusic).l
                st.b    objoff_3E(a0)

loc_3610C:
                cmpi.b  #6,anim(a0)
                blo.s   ChaosEmerald_Return
                move.w  (Ring_count).w,d2
                add.w   (Ring_count_2P).w,d2
                cmp.w   (SS_Ring_Requirement).w,d2
                blt.s   loc_36142
                cmpi.b  #9,anim(a0)
                blo.s   ChaosEmerald_Return
                move.w  #$63,objoff_2A(a0)
                move.b  #8,routine(a0)
                move.w  #MusID_Emerald,d0
                jsr     (PlayMusic).l

ChaosEmerald_Return:
                rts
; ===========================================================================

loc_36142:
                move.l  #0,(SS_New_Speed_Factor).w
                move.b  #6,routine(a0)
                move.w  #$4F,objoff_2A(a0)
                move.w  #6,d0
                bsr.w   SpecialStageMessage_PrintPhrase
                rts
; ===========================================================================

loc_36160:
                subi_.w #1,objoff_2A(a0)
                bpl.w   JmpTo44_DisplaySprite
                st.b    (SS_Check_Rings_flag).w
                bra.w   SSClearObjs
; ===========================================================================

loc_36172:
                subi_.w #1,objoff_2A(a0)
                bpl.s   loc_361A4
                moveq   #0,d0
                move.b  (Current_Special_Stage).w,d0
                lea     (Got_Emeralds_array).w,a0
                st.b    (a0,d0.w)
                st.b    (Got_Emerald).w
                addi_.b #1,(Current_Special_Stage).w
                addi_.b #1,(Emerald_count).w
                st.b    (SS_Check_Rings_flag).w
                bsr.w   SSClearObjs
                move.l  (sp)+,d0
                rts
; ===========================================================================

loc_361A4:
                addi_.b #1,objoff_3C(a0)
                moveq   #0,d0
                moveq   #0,d2
                move.b  objoff_3B(a0),d2
                move.b  objoff_3C(a0),d0
                lsr.w   #2,d0
                andi.w  #3,d0
                add.b   byte_361C8(pc,d0.w),d2
                move.w  d2,y_pos(a0)
                jmpto   JmpTo44_DisplaySprite
; ===========================================================================
byte_361C8:
                dc.b    $FF
                dc.b    0                               ; 1
                dc.b    1                               ; 2
                dc.b    0                               ; 3
                even
; ===========================================================================
; loc_361CC
SSClearObjs:
                movea.l #(Object_RAM&$FFFFFF),a1

                move.w  #(Object_RAM_End-Object_RAM)/$10-1,d0
                moveq   #0,d1

ChaosEmerald_CountedLoopD0:
                rept    $10/4
                move.l  d1,(a1)+
                endm
                dbf     d0,ChaosEmerald_CountedLoopD0
.c              :=      ((Object_RAM_End-Object_RAM)#$10)/4
                if      .c
                rept    .c
                move.l  d1,(a1)+
                endm
                endif
.c              :=      ((Object_RAM_End-Object_RAM)#$10)&2
                if      .c
                rept    .c
                move.w  d1,(a1)+
                endm
                endif

; The '+4' shouldn't be here; clearRAM accidentally clears an additional 4 bytes
                clearRAM Sprite_Table,Sprite_Table_End+4

                rts
; ===========================================================================
; unused/dead code ; a0=object
                cmpi.b  #$B,(SSTrack_drawing_index).w
                blo.s   loc_36208
                subi.l  #$4445,objoff_30(a0)
                bra.s   loc_36210
; ---------------------------------------------------------------------------
loc_36208:
                subi.l  #$4444,objoff_30(a0)
loc_36210:
                move.w  objoff_30(a0),d0
                cmpi.w  #$1D,d0
                ble.s   +
                moveq   #$1E,d0
+
                lea_    byte_35180,a1
                move.b  (a1,d0.w),anim(a0)
                rts
; end of unused code

; ===========================================================================
; animation script for object 59
ChaosEmerald_Animation: offsetTable
                offsetTableEntry.w ChaosEmerald_Animation_Sequence0  ; 0
                offsetTableEntry.w ChaosEmerald_Animation_Sequence1  ; 1
                offsetTableEntry.w ChaosEmerald_Animation_Sequence2  ; 2
                offsetTableEntry.w ChaosEmerald_Animation_Sequence3  ; 3
                offsetTableEntry.w ChaosEmerald_Animation_Sequence4  ; 4
                offsetTableEntry.w ChaosEmerald_Animation_Sequence5  ; 5
                offsetTableEntry.w ChaosEmerald_Animation_Sequence6  ; 6
                offsetTableEntry.w ChaosEmerald_Animation_Sequence7  ; 7
                offsetTableEntry.w ChaosEmerald_Animation_Sequence8  ; 8
                offsetTableEntry.w ChaosEmerald_Animation_Sequence9  ; 9
ChaosEmerald_Animation_Sequence0:
                dc.b    $B,  0,$FF
ChaosEmerald_Animation_Sequence1:
                dc.b    $B,  1,$FF
ChaosEmerald_Animation_Sequence2:
                dc.b    $B,  2,$FF
ChaosEmerald_Animation_Sequence3:
                dc.b    $B,  3,$FF
ChaosEmerald_Animation_Sequence4:
                dc.b    $B,  4,$FF
ChaosEmerald_Animation_Sequence5:
                dc.b    $B,  5,$FF
ChaosEmerald_Animation_Sequence6:
                dc.b    $B,  6,$FF
ChaosEmerald_Animation_Sequence7:
                dc.b    $B,  7,$FF
ChaosEmerald_Animation_Sequence8:
                dc.b    $B,  8,$FF
ChaosEmerald_Animation_Sequence9:
                dc.b    $B,  9,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj59_MapUnc_3625A:
Map_obj59:      mappingsTable
                mappingsTableEntry.w Map_obj59_0014
                mappingsTableEntry.w Map_obj59_001E
                mappingsTableEntry.w Map_obj59_0028
                mappingsTableEntry.w Map_obj59_0032
                mappingsTableEntry.w Map_obj59_003C
                mappingsTableEntry.w Map_obj59_0046
                mappingsTableEntry.w Map_obj59_0050
                mappingsTableEntry.w Map_obj59_005A
                mappingsTableEntry.w Map_obj59_0064
                mappingsTableEntry.w Map_obj59_006E

Map_obj59_0014: spriteHeader
                spritePiece -4, -4, 1, 1, 0, 0, 0, 0, 1
Map_obj59_0014_End

Map_obj59_001E: spriteHeader
                spritePiece -4, -4, 1, 1, 1, 0, 0, 0, 1
Map_obj59_001E_End

Map_obj59_0028: spriteHeader
                spritePiece -4, -4, 1, 1, 2, 0, 0, 0, 1
Map_obj59_0028_End

Map_obj59_0032: spriteHeader
                spritePiece -8, -8, 2, 2, 3, 0, 0, 0, 1
Map_obj59_0032_End

Map_obj59_003C: spriteHeader
                spritePiece -8, -8, 2, 2, 7, 0, 0, 0, 1
Map_obj59_003C_End

Map_obj59_0046: spriteHeader
                spritePiece -8, -8, 2, 2, $B, 0, 0, 0, 1
Map_obj59_0046_End

Map_obj59_0050: spriteHeader
                spritePiece -8, -8, 2, 2, $F, 0, 0, 0, 1
Map_obj59_0050_End

Map_obj59_005A: spriteHeader
                spritePiece -$C, -$C, 3, 3, $13, 0, 0, 0, 1
Map_obj59_005A_End

Map_obj59_0064: spriteHeader
                spritePiece -$C, -$C, 3, 3, $1C, 0, 0, 0, 1
Map_obj59_0064_End

Map_obj59_006E: spriteHeader
                spritePiece -$C, -$C, 3, 3, $25, 0, 0, 0, 1
Map_obj59_006E_End

                even

; animation script:
; off_362D2:
Ani_obj5B_obj60:offsetTable
                offsetTableEntry.w ChaosEmerald_Animation_Sequence0_Variant2  ; 0
                offsetTableEntry.w ChaosEmerald_Animation_Sequence1_Variant2  ; 1
                offsetTableEntry.w ChaosEmerald_Animation_Sequence2_Variant2  ; 2
                offsetTableEntry.w ChaosEmerald_Animation_Sequence3_Variant2  ; 3
                offsetTableEntry.w ChaosEmerald_Animation_Sequence4_Variant2  ; 4
                offsetTableEntry.w ChaosEmerald_Animation_Sequence5_Variant2  ; 5
                offsetTableEntry.w ChaosEmerald_Animation_Sequence6_Variant2  ; 6
                offsetTableEntry.w ChaosEmerald_Animation_Sequence7_Variant2  ; 7
                offsetTableEntry.w ChaosEmerald_Animation_Sequence8_Variant2  ; 8
                offsetTableEntry.w ChaosEmerald_Animation_Sequence9_Variant2  ; 9
                offsetTableEntry.w ChaosEmerald_Animation_Sequence10  ; $A
ChaosEmerald_Animation_Sequence0_Variant2:  dc.b    5,  0, $A,$14, $A,$FF
ChaosEmerald_Animation_Sequence1_Variant2:  dc.b    5,  1, $B,$15, $B,$FF
ChaosEmerald_Animation_Sequence2_Variant2:  dc.b    5,  2, $C,$16, $C,$FF
ChaosEmerald_Animation_Sequence3_Variant2:  dc.b    5,  3, $D,$17, $D,$FF
ChaosEmerald_Animation_Sequence4_Variant2:  dc.b    5,  4, $E,$18, $E,$FF
ChaosEmerald_Animation_Sequence5_Variant2:  dc.b    5,  5, $F,$19, $F,$FF
ChaosEmerald_Animation_Sequence6_Variant2:  dc.b    5,  6,$10,$1A,$10,$FF
ChaosEmerald_Animation_Sequence7_Variant2:  dc.b    5,  7,$11,$1B,$11,$FF
ChaosEmerald_Animation_Sequence8_Variant2:  dc.b    5,  8,$12,$1C,$12,$FF
ChaosEmerald_Animation_Sequence9_Variant2:  dc.b    5,  9,$13,$1D,$13,$FF
ChaosEmerald_Animation_Sequence10:          dc.b    1,$1E,$1F,$20,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj5A_Obj5B_Obj60_MapUnc_3632A: include "src/game/special_stage/objects/messages/data/mappings_shared.s"

; animation script:
; off_364CE:
Ani_obj61:      offsetTable
                offsetTableEntry.w ChaosEmerald_Animation_Sequence0_Variant3  ; 0
                offsetTableEntry.w ChaosEmerald_Animation_Sequence1_Variant3  ; 1
                offsetTableEntry.w ChaosEmerald_Animation_Sequence2_Variant3  ; 2
                offsetTableEntry.w ChaosEmerald_Animation_Sequence3_Variant3  ; 3
                offsetTableEntry.w ChaosEmerald_Animation_Sequence4_Variant3  ; 4
                offsetTableEntry.w ChaosEmerald_Animation_Sequence5_Variant3  ; 5
                offsetTableEntry.w ChaosEmerald_Animation_Sequence6_Variant3  ; 6
                offsetTableEntry.w ChaosEmerald_Animation_Sequence7_Variant3  ; 7
                offsetTableEntry.w ChaosEmerald_Animation_Sequence8_Variant3  ; 8
                offsetTableEntry.w ChaosEmerald_Animation_Sequence9_Variant3  ; 9
                offsetTableEntry.w ChaosEmerald_Animation_Sequence10_Variant2  ; $A
ChaosEmerald_Animation_Sequence0_Variant3:  dc.b    $B,  0,$FF
ChaosEmerald_Animation_Sequence1_Variant3:  dc.b    $B,  1,$FF
ChaosEmerald_Animation_Sequence2_Variant3:  dc.b    $B,  2,$FF
ChaosEmerald_Animation_Sequence3_Variant3:  dc.b    $B,  3,$FF
ChaosEmerald_Animation_Sequence4_Variant3:  dc.b    $B,  4,$FF
ChaosEmerald_Animation_Sequence5_Variant3:  dc.b    $B,  5,$FF
ChaosEmerald_Animation_Sequence6_Variant3:  dc.b    $B,  6,$FF
ChaosEmerald_Animation_Sequence7_Variant3:  dc.b    $B,  7,$FF
ChaosEmerald_Animation_Sequence8_Variant3:  dc.b    $B,  8,$FF
ChaosEmerald_Animation_Sequence9_Variant3:  dc.b    $B,  9,$FF
ChaosEmerald_Animation_Sequence10_Variant2: dc.b    2, $A, $B, $C,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj61_MapUnc_36508: include "src/game/special_stage/objects/rings_bombs/mappings.s"
; ===========================================================================

                jmpTos0 JmpTo44_DisplaySprite,JmpTo63_DeleteObject,JmpTo24_AnimateSprite,JmpTo_SSStartNewAct,JmpTo_CalcAngle,JmpTo14_CalcSine,JmpTo7_ObjectMoveAndFall,JmpTo_SSAllocateObjectAfterCurrent,JmpTo2_SSAllocateObject

; ===========================================================================

; ---------------------------------------------------------------------------
; LoadSubObject
; loads information from a sub-object into this object a0
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_365F4:
