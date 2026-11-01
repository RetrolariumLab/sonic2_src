Obj63:
                movea.l ss_parent(a0),a1                ; a1=object
                cmpa.l  #MainCharacter,a1
                bne.s   loc_340BC
                movea.l #MainCharacter,a1               ; a1=character
                bsr.s   SpecialStageShadow_ProjectPlayerPosition
                jmpto   JmpTo42_DisplaySprite
; ===========================================================================

loc_340BC:
                movea.l #Sidekick,a1                    ; a1=object
                bsr.s   SpecialStageShadow_ProjectPlayerPosition
                bsr.w   SpecialStageShadow_AdjustAnimationOffset
                jmpto   JmpTo42_DisplaySprite
; ===========================================================================

SpecialStageShadow_ProjectPlayerPosition:
                cmpi.b  #2,routine(a1)
                beq.w   loc_34108
                bsr.w   SpecialStagePlayer_CalculateTrackAngle
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  ss_z_pos(a1),d1
                muls.w  #$CC,d1
                swap    d1
                add.w   (SS_Offset_X).w,d1
                move.w  d1,x_pos(a0)
                muls.w  ss_z_pos(a1),d0
                asr.l   #8,d0
                add.w   (SS_Offset_Y).w,d0
                move.w  d0,y_pos(a0)
                bra.w   loc_3411A
; ===========================================================================

loc_34108:
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  angle(a1),angle(a0)

loc_3411A:
                moveq   #0,d0
                move.b  angle(a0),d0
                subi.b  #$10,d0
                lsr.b   #5,d0
                move.b  d0,d1
                lsl.w   #3,d0
                lea     SpecialStageShadow_OrientationRecords(pc),a2
                adda.w  d0,a2
                move.w  (a2)+,art_tile(a0)
                move.w  (a2)+,d0
                add.w   d0,x_pos(a0)
                move.w  (a2)+,d0
                add.w   d0,y_pos(a0)
                move.b  (a2)+,mapping_frame(a0)
                move.b  render_flags(a0),d0
                andi.b  #~(1<<render_flags.x_flip|1<<render_flags.y_flip),d0
                or.b    (a2)+,d0
                move.b  d0,render_flags(a0)
                tst.b   angle(a0)
                bpl.s   CharacterShadow_Return
                cmpi.b  #3,d1
                beq.s   loc_34164
                cmpi.b  #7,d1
                bne.s   loc_3416A

loc_34164:
                addi_.b #3,mapping_frame(a0)

loc_3416A:
                move.w  (SS_Offset_Y).w,d1
                sub.w   y_pos(a0),d1
                add.w   d1,d1
                add.w   d1,y_pos(a0)

CharacterShadow_Return:
                rts
; ===========================================================================
obj63_data      macro   artTile,xOffset,yOffset,frame,xFlip
                    dc.w    make_art_tile(artTile,3,0), xOffset, yOffset
                    dc.b    frame,xFlip<<render_flags.x_flip
                endm

SpecialStageShadow_OrientationRecords:
                obj63_data ArtTile_ArtNem_SpecialDiagShadow,  $14,  $14,    1,  TRUE  ; 0
                obj63_data ArtTile_ArtNem_SpecialFlatShadow,    0,  $18,    0, FALSE  ; 4
                obj63_data ArtTile_ArtNem_SpecialDiagShadow, -$14,  $14,    1, FALSE  ; 8
                obj63_data ArtTile_ArtNem_SpecialSideShadow, -$14,    0,    2, FALSE  ; 12
                obj63_data ArtTile_ArtNem_SpecialDiagShadow, -$14, -$14,    7, FALSE  ; 16
                obj63_data ArtTile_ArtNem_SpecialFlatShadow,    0, -$18,    9, FALSE  ; 20
                obj63_data ArtTile_ArtNem_SpecialDiagShadow,  $14, -$14,    7,  TRUE  ; 24
                obj63_data ArtTile_ArtNem_SpecialSideShadow,  $14,    0,    2,  TRUE  ; 28
; ===========================================================================

SpecialStageShadow_AdjustAnimationOffset:
                cmpi.b  #1,anim(a1)
                bne.s   CharacterShadow_Return_Variant2
                move.b  status(a1),d1
                andi.w  #1<<status.npc.x_flip|1<<status.npc.y_flip,d1
                cmpi.b  #1<<status.npc.y_flip,d1
                bhs.s   CharacterShadow_Return_Variant2
                move.b  byte_341E2(pc,d1.w),d0
                ext.w   d0
                add.w   d0,x_pos(a0)
                subi_.w #4,y_pos(a0)

CharacterShadow_Return_Variant2:
                rts
; ===========================================================================
; animation script
byte_341E2:     dc.b    4, -4
CharacterShadow_Animation:      offsetTable
                offsetTableEntry.w CharacterShadow_Animation_Sequence0           ; 0
                offsetTableEntry.w CharacterShadow_Animation_Sequence1           ; 1
                offsetTableEntry.w CharacterShadow_Animation_Sequence2           ; 2
                offsetTableEntry.w CharacterShadow_Animation_Sequence3           ; 3
                offsetTableEntry.w CharacterShadow_Animation_Sequence4           ; 4
CharacterShadow_Animation_Sequence0:
                dc.b    3,  0,  1,  2,  3,$FF
CharacterShadow_Animation_Sequence1:
                dc.b    3,  4,  5,  6,  7,  8,  9, $A, $B,$FF
CharacterShadow_Animation_Sequence2:
                dc.b    3, $C, $D, $E, $F,$FF
CharacterShadow_Animation_Sequence3:
                dc.b    1,$10,$11,$FF
CharacterShadow_Animation_Sequence4:
                dc.b    3,  0,  4, $C,  4,  0,  4, $C,  4,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_SpecialSonicAndTails
; ----------------------------------------------------------------------------
Obj09_MapUnc_34212: include "src/game/objects/09_sonic_in_special_stage/data/mappings_obj09.asm"
; ----------------------------------------------------------------------------
; sprite mappings for special stage shadows
; ----------------------------------------------------------------------------
Obj63_MapUnc_34492: include "src/game/objects/63_special_stage_character_shadow/data/mappings_obj63.asm"
; ----------------------------------------------------------------------------
; custom dynamic pattern loading cues for special stage Sonic, Tails and
; Tails' tails
; The first $12 frames are for Sonic, and the next $12 frames are for Tails
; The last $15 frames are for Tails' tails
; The first $24 frames are almost normal dplcs -- the only difference being
; that the art tile to load is pre-shifted left by 4 bits
; The same applies to the last $15 frames, but they have yet another difference:
; a small space optimization. These frames only have one dplc per frame ever,
; hence the two-byte dplc count is removed from each frame
; ----------------------------------------------------------------------------
                pushv   ,SonicDplcVer                   ; Backup previous value of SonicDplcVer
SonicDplcVer    :=      4                               ; Switch to custom DPLC format

Obj09_MapRUnc_345FA:    mappingsTable
                mappingsTableEntry.w .sonic_0
                mappingsTableEntry.w .sonic_1
                mappingsTableEntry.w .sonic_2
                mappingsTableEntry.w .sonic_3
                mappingsTableEntry.w .sonic_4
                mappingsTableEntry.w .sonic_5
                mappingsTableEntry.w .sonic_6
                mappingsTableEntry.w .sonic_7
                mappingsTableEntry.w .sonic_8
                mappingsTableEntry.w .sonic_9
                mappingsTableEntry.w .sonic_10
                mappingsTableEntry.w .sonic_11
                mappingsTableEntry.w .sonic_12
                mappingsTableEntry.w .sonic_13
                mappingsTableEntry.w .sonic_14
                mappingsTableEntry.w .sonic_15
                mappingsTableEntry.w .sonic_16
                mappingsTableEntry.w .sonic_17

                mappingsTableEntry.w .tails_0
                mappingsTableEntry.w .tails_1
                mappingsTableEntry.w .tails_2
                mappingsTableEntry.w .tails_3
                mappingsTableEntry.w .tails_4
                mappingsTableEntry.w .tails_5
                mappingsTableEntry.w .tails_6
                mappingsTableEntry.w .tails_7
                mappingsTableEntry.w .tails_8
                mappingsTableEntry.w .tails_9
                mappingsTableEntry.w .tails_10
                mappingsTableEntry.w .tails_11
                mappingsTableEntry.w .tails_12
                mappingsTableEntry.w .tails_13
                mappingsTableEntry.w .tails_14
                mappingsTableEntry.w .tails_15
                mappingsTableEntry.w .tails_16
                mappingsTableEntry.w .tails_17

                mappingsTableEntry.w .tails_tails_0
                mappingsTableEntry.w .tails_tails_1
                mappingsTableEntry.w .tails_tails_2
                mappingsTableEntry.w .tails_tails_3
                mappingsTableEntry.w .tails_tails_4
                mappingsTableEntry.w .tails_tails_5
                mappingsTableEntry.w .tails_tails_6
                mappingsTableEntry.w .tails_tails_7
                mappingsTableEntry.w .tails_tails_8
                mappingsTableEntry.w .tails_tails_9
                mappingsTableEntry.w .tails_tails_10
                mappingsTableEntry.w .tails_tails_11
                mappingsTableEntry.w .tails_tails_12
                mappingsTableEntry.w .tails_tails_13
                mappingsTableEntry.w .tails_tails_14
                mappingsTableEntry.w .tails_tails_15
                mappingsTableEntry.w .tails_tails_16
                mappingsTableEntry.w .tails_tails_17
                mappingsTableEntry.w .tails_tails_18
                mappingsTableEntry.w .tails_tails_19
                mappingsTableEntry.w .tails_tails_20

.sonic_0:       dplcHeader
                dplcEntry $10, 0
                dplcEntry 9, $10
                dplcEntry 2, $19
.sonic_0_End

.sonic_1:       dplcHeader
                dplcEntry 9, $1B
                dplcEntry 8, $24
                dplcEntry 4, $2C
.sonic_1_End

.sonic_2:       dplcHeader
                dplcEntry $C, $30
                dplcEntry 8, $3C
                dplcEntry 6, $44
.sonic_2_End

.sonic_3:       dplcHeader
                dplcEntry 9, $1B
                dplcEntry 8, $4A
                dplcEntry 6, $52
.sonic_3_End

.sonic_4:       dplcHeader
                dplcEntry 9, 0
                dplcEntry 4, 9
                dplcEntry 2, $D
                dplcEntry $C, $F
.sonic_4_End

.sonic_5:       dplcHeader
                dplcEntry 6, $1B
                dplcEntry 2, $21
                dplcEntry 8, $23
                dplcEntry 8, $2B
                dplcEntry 1, $33
.sonic_5_End

.sonic_6:       dplcHeader
                dplcEntry 2, $34
                dplcEntry $C, $36
                dplcEntry 3, $42
                dplcEntry 6, $45
                dplcEntry 4, $4B
.sonic_6_End

.sonic_7:       dplcHeader
                dplcEntry 2, $4F
                dplcEntry $10, $51
                dplcEntry 3, $61
                dplcEntry 1, $64
                dplcEntry 4, $65
.sonic_7_End

.sonic_8:       dplcHeader
                dplcEntry 4, $69
                dplcEntry 4, $6D
                dplcEntry $C, $71
                dplcEntry 4, $7D
.sonic_8_End

.sonic_9:       dplcHeader
                dplcEntry 4, $81
                dplcEntry 3, $85
                dplcEntry 8, $88
                dplcEntry 8, $90
                dplcEntry 1, $98
.sonic_9_End

.sonic_10:      dplcHeader
                dplcEntry 6, $99
                dplcEntry 2, $9F
                dplcEntry 8, $A1
                dplcEntry 8, $A9
                dplcEntry 1, $B1
.sonic_10_End

.sonic_11:      dplcHeader
                dplcEntry 1, $B2
                dplcEntry 8, $B3
                dplcEntry 1, $BB
                dplcEntry 2, $BC
                dplcEntry 8, $BE
                dplcEntry 6, $C6
.sonic_11_End

.sonic_12:      dplcHeader
                dplcEntry 6, 0
                dplcEntry 1, 6
                dplcEntry $10, 7
.sonic_12_End

.sonic_13:      dplcHeader
                dplcEntry 6, $17
                dplcEntry 4, $1D
                dplcEntry $C, $21
.sonic_13_End

.sonic_14:      dplcHeader
                dplcEntry 3, $2D
                dplcEntry 3, $30
                dplcEntry $10, $33
.sonic_14_End

.sonic_15:      dplcHeader
                dplcEntry 6, $43
                dplcEntry 4, $49
                dplcEntry $C, $21
.sonic_15_End

.sonic_16:      dplcHeader
                dplcEntry 8, 0
                dplcEntry 2, 8
.sonic_16_End

.sonic_17:      dplcHeader
                dplcEntry 8, $A
                dplcEntry 2, 8
.sonic_17_End

.tails_0:       dplcHeader
                dplcEntry 9, 0
                dplcEntry 6, 9
                dplcEntry 1, $F
.tails_0_End

.tails_1:       dplcHeader
                dplcEntry 4, $10
                dplcEntry 6, $14
                dplcEntry 4, $1A
                dplcEntry 4, $1E
.tails_1_End

.tails_2:       dplcHeader
                dplcEntry 4, $22
                dplcEntry 6, $26
                dplcEntry 4, $2C
                dplcEntry 4, $30
.tails_2_End

.tails_3:       dplcHeader
                dplcEntry 4, $10
                dplcEntry 6, $14
                dplcEntry 4, $34
                dplcEntry 4, $38
                dplcEntry 1, $3C
.tails_3_End

.tails_4:       dplcHeader
                dplcEntry 4, 0
                dplcEntry 8, 4
                dplcEntry 8, $C
.tails_4_End

.tails_5:       dplcHeader
                dplcEntry 2, $14
                dplcEntry 8, $16
                dplcEntry 9, $1E
                dplcEntry 2, $27
.tails_5_End

.tails_6:       dplcHeader
                dplcEntry 1, $29
                dplcEntry 3, $2A
                dplcEntry 8, $2D
                dplcEntry 1, $35
                dplcEntry 6, $36
.tails_6_End

.tails_7:       dplcHeader
                dplcEntry 1, $3C
                dplcEntry $10, $3D
                dplcEntry 1, $4D
                dplcEntry 2, $4E
.tails_7_End

.tails_8:       dplcHeader
                dplcEntry 4, $50
                dplcEntry 4, $54
                dplcEntry 8, $58
                dplcEntry 6, $60
.tails_8_End

.tails_9:       dplcHeader
                dplcEntry 1, $66
                dplcEntry 8, $67
                dplcEntry 1, $6F
                dplcEntry 8, $70
                dplcEntry 2, $78
.tails_9_End

.tails_10:      dplcHeader
                dplcEntry 1, $7A
                dplcEntry $C, $7B
                dplcEntry 1, $87
                dplcEntry 4, $88
                dplcEntry 2, $8C
.tails_10_End

.tails_11:      dplcHeader
                dplcEntry 1, $8E
                dplcEntry $C, $8F
                dplcEntry 1, $9B
                dplcEntry 8, $9C
.tails_11_End

.tails_12:      dplcHeader
                dplcEntry 9, 0
                dplcEntry 8, 9
.tails_12_End

.tails_13:      dplcHeader
                dplcEntry 4, $11
                dplcEntry 1, $15
                dplcEntry $C, $16
.tails_13_End

.tails_14:      dplcHeader
                dplcEntry 2, $22
                dplcEntry $10, $24
.tails_14_End

.tails_15:      dplcHeader
                dplcEntry 3, $34
                dplcEntry 3, $37
                dplcEntry $C, $16
.tails_15_End

.tails_16:      dplcHeader
                dplcEntry 8, 0
.tails_16_End

.tails_17:      dplcHeader
                dplcEntry 8, 8
.tails_17_End

.tails_tails_0:                                         ; dplcHeader
                dplcEntry 6, 0
.tails_tails_0_End

.tails_tails_1:                                         ; dplcHeader
                dplcEntry 9, 6
.tails_tails_1_End

.tails_tails_2:                                         ; dplcHeader
                dplcEntry 6, $F
.tails_tails_2_End

.tails_tails_3:                                         ; dplcHeader
                dplcEntry 6, $15
.tails_tails_3_End

.tails_tails_4:                                         ; dplcHeader
                dplcEntry 8, $1B
.tails_tails_4_End

.tails_tails_5:                                         ; dplcHeader
                dplcEntry 9, $23
.tails_tails_5_End

.tails_tails_6:                                         ; dplcHeader
                dplcEntry 9, $2C
.tails_tails_6_End

.tails_tails_7:                                         ; dplcHeader
                dplcEntry 9, 0
.tails_tails_7_End

.tails_tails_8:                                         ; dplcHeader
                dplcEntry 6, 9
.tails_tails_8_End

.tails_tails_9:                                         ; dplcHeader
                dplcEntry 6, $F
.tails_tails_9_End

.tails_tails_10:                                        ; dplcHeader
                dplcEntry 8, $15
.tails_tails_10_End

.tails_tails_11:                                        ; dplcHeader
                dplcEntry $C, $1D
.tails_tails_11_End

.tails_tails_12:                                        ; dplcHeader
                dplcEntry 9, $29
.tails_tails_12_End

.tails_tails_13:                                        ; dplcHeader
                dplcEntry 9, $32
.tails_tails_13_End

.tails_tails_14:                                        ; dplcHeader
                dplcEntry 6, 0
.tails_tails_14_End

.tails_tails_15:                                        ; dplcHeader
                dplcEntry 9, 6
.tails_tails_15_End

.tails_tails_16:                                        ; dplcHeader
                dplcEntry 6, $F
.tails_tails_16_End

.tails_tails_17:                                        ; dplcHeader
                dplcEntry 6, $15
.tails_tails_17_End

.tails_tails_18:                                        ; dplcHeader
                dplcEntry 8, $1B
.tails_tails_18_End

.tails_tails_19:                                        ; dplcHeader
                dplcEntry 9, $23
.tails_tails_19_End

.tails_tails_20:                                        ; dplcHeader
                dplcEntry 9, $2C
.tails_tails_20_End

                even

                popv    ,SonicDplcVer                   ; Switch back to the previous DPLC format
; ===========================================================================

                jmpTos  JmpTo42_DisplaySprite,JmpTo_SSAllocateObject

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 10 - Tails in Special Stage
; ----------------------------------------------------------------------------
; Sprite_347EC:
