ObjC7_PositionChildren:
                moveq   #0,d0
                moveq   #0,d6

                move.b  (a1)+,d6
-               move.b  (a1)+,d0
                movea.w (a0,d0.w),a2                    ; a2=object
                move.w  x_pos(a0),d1
                move.b  (a1)+,d2
                ext.w   d2
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d2
+
                add.w   d2,d1
                move.w  d1,x_pos(a2)
                move.w  y_pos(a0),d1
                move.b  (a1)+,d2
                ext.w   d2
                add.w   d2,d1
                move.w  d1,y_pos(a2)
                dbf     d6,-
                rts
; ===========================================================================
; byte_3E2E0
ObjC7_ChildDeltas:
                dc.b    6
                dc.b    objoff_2E, $FC, $3C             ; 1
                dc.b    objoff_30, $F4,   8             ; 2
                dc.b    objoff_32,  $C, $F8             ; 3
                dc.b    objoff_34,   4, $24             ; 4
                dc.b    objoff_3A, $FC, $3C             ; 5
                dc.b    objoff_3C, $F4,   8             ; 6
                dc.b    objoff_3E,   4, $24             ; 7
                even
DeathEggRobot_LimbMotionProgram1:
                dc.l    ObjC7_GroupAni_3E318
                dc.b    0, 1, 2, 3, $FF, 0
                even
DeathEggRobot_LimbMotionProgram2:
                dc.l    ObjC7_GroupAni_3E318
                dc.b    5, 6, 7, 8, $FF, 0
                even
DeathEggRobot_LimbMotionProgram3:
                dc.l    ObjC7_GroupAni_3E318
                dc.b    0, 1, 2, 3, 4, 5, 6, 7, 8, $C0
                even
; -----------------------------------------------------------------------------
; Custom animation
; -----------------------------------------------------------------------------
; must be on the same line as a label that has a corresponding _End label later
c7anilistheader     macro   maxframe,{INTLABEL}
__LABEL__           label   *
                    dc.b    ((__LABEL___End - __LABEL__ - 2) / 3) - 1,maxframe
                endm

; macro for a animation data
c7ani           macro   pieceOffset,deltax,deltay
                        dc.b    pieceOffset,deltax,deltay
                    endm

ObjC7_GroupAni_3E318:   offsetTable                     ; include "mappings/sprite/objC7_a.asm"
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame0
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame1
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame2
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame3
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame4
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame5
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame6
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame7
                    offsetTableEntry.w DeathEggRobot_LimbMotion1_Frame8

DeathEggRobot_LimbMotion1_Frame0:   c7anilistheader 8
                    c7ani   $00, $E0, $0C
                    c7ani   objoff_30, $E0, $0C
                    c7ani   objoff_32, $E0, $0C
                    c7ani   objoff_3C, $E0, $0C
                    c7ani   objoff_34, $F8, $04
                    c7ani   objoff_3E, $F8, $04
DeathEggRobot_LimbMotion1_Frame0_End

DeathEggRobot_LimbMotion1_Frame1:   c7anilistheader 8
                    c7ani   $00, $EC, $14
                    c7ani   objoff_30, $EC, $14
                    c7ani   objoff_32, $EC, $14
                    c7ani   objoff_3C, $EC, $14
                    c7ani   objoff_34, $FA, $06
                    c7ani   objoff_3E, $FA, $06
DeathEggRobot_LimbMotion1_Frame1_End

DeathEggRobot_LimbMotion1_Frame2:   c7anilistheader 8
                    c7ani   $00, $F8, $14
                    c7ani   objoff_30, $F8, $14
                    c7ani   objoff_32, $F8, $14
                    c7ani   objoff_3C, $F8, $14
                    c7ani   objoff_34, $FE, $04
                    c7ani   objoff_3E, $FE, $04
DeathEggRobot_LimbMotion1_Frame2_End

DeathEggRobot_LimbMotion1_Frame3:   c7anilistheader 8
                    c7ani   $00, $FC, $0C
                    c7ani   objoff_30, $FC, $0C
                    c7ani   objoff_32, $FC, $0C
                    c7ani   objoff_3C, $FC, $0c
                    c7ani   objoff_34, $00, $02
                    c7ani   objoff_3E, $00, $02
DeathEggRobot_LimbMotion1_Frame3_End

DeathEggRobot_LimbMotion1_Frame4:   c7anilistheader 8
                    c7ani   $00, $00, $00
DeathEggRobot_LimbMotion1_Frame4_End
                    even
DeathEggRobot_LimbMotion1_Frame5:   c7anilistheader 8
                    c7ani   $00, $04, $E8
                    c7ani   objoff_30, $04, $E8
                    c7ani   objoff_32, $04, $E8
                    c7ani   objoff_3C, $04, $E8
                    c7ani   objoff_34, $02, $FA
                    c7ani   objoff_3E, $02, $FA
DeathEggRobot_LimbMotion1_Frame5_End

DeathEggRobot_LimbMotion1_Frame6:   c7anilistheader 8
                    c7ani   $00, $0C, $E8
                    c7ani   objoff_30, $0C, $E8
                    c7ani   objoff_32, $0C, $E8
                    c7ani   objoff_3C, $0C, $E8
                    c7ani   objoff_34, $04, $FC
                    c7ani   objoff_3E, $04, $FC
DeathEggRobot_LimbMotion1_Frame6_End

DeathEggRobot_LimbMotion1_Frame7:   c7anilistheader 8
                    c7ani   $00, $18, $F4
                    c7ani   objoff_30, $18, $F4
                    c7ani   objoff_32, $18, $F4
                    c7ani   objoff_3C, $18, $F4
                    c7ani   objoff_34, $04, $FC
                    c7ani   objoff_3E, $04, $FC
DeathEggRobot_LimbMotion1_Frame7_End

DeathEggRobot_LimbMotion1_Frame8:   c7anilistheader 8
                    c7ani   $00, $18, $FC
                    c7ani   objoff_30, $18, $FC
                    c7ani   objoff_32, $18, $FC
                    c7ani   objoff_3C, $18, $FC
                    c7ani   objoff_34, $06, $FE
                    c7ani   objoff_3E, $06, $FE
DeathEggRobot_LimbMotion1_Frame8_End

DeathEggRobot_LimbMotionProgram4:
                    dc.l    ObjC7_GroupAni_3E3D8
                    dc.b    0, 1, 2, $C0
                    even
; -----------------------------------------------------------------------------
; Custom animation
; -----------------------------------------------------------------------------
ObjC7_GroupAni_3E3D8:   offsetTable                     ; include "mappings/sprite/objC7_b.asm"
                    offsetTableEntry.w DeathEggRobot_LimbMotion2_Frame0
                    offsetTableEntry.w DeathEggRobot_LimbMotion2_Frame1
                    offsetTableEntry.w DeathEggRobot_LimbMotion2_Frame2

DeathEggRobot_LimbMotion2_Frame0:   c7anilistheader $10
                    c7ani   $00, $00, $04
                    c7ani   objoff_30, $00, $04
                    c7ani   objoff_32, $00, $04
                    c7ani   objoff_3C, $00, $04
                    c7ani   objoff_34, $00, $04
                    c7ani   objoff_3E, $00, $04
DeathEggRobot_LimbMotion2_Frame0_End

DeathEggRobot_LimbMotion2_Frame1:   c7anilistheader $10
                    c7ani   $00, $00, $00
DeathEggRobot_LimbMotion2_Frame1_End
                    even
DeathEggRobot_LimbMotion2_Frame2:   c7anilistheader 8
                    c7ani   $00, $00, $F8
                    c7ani   objoff_30, $00, $F8
                    c7ani   objoff_32, $00, $F8
                    c7ani   objoff_3C, $00, $F8
                    c7ani   objoff_34, $00, $F8
                    c7ani   objoff_3E, $00, $F8
DeathEggRobot_LimbMotion2_Frame2_End

DeathEggRobot_LimbMotionProgram5:
                    dc.l    ObjC7_GroupAni_3E438
                    dc.b    0,  1,  2,  3, $40, SndID_Hammer
                    dc.b    4,  5,  6,  7,   8, $40, SndID_Hammer
                    dc.b    9, $A,  1,  2,   3, $40, SndID_Hammer
                    dc.b    4,  5,  6,  7,   8, $40, SndID_Hammer, $C0
                    even
DeathEggRobot_LimbMotionProgram6:
                    dc.l    ObjC7_GroupAni_3E438
                    dc.b    $88, $87, $86, $85, $B, $40, SndID_Hammer, $C0
                    even
; -----------------------------------------------------------------------------
; Custom animation
; -----------------------------------------------------------------------------
ObjC7_GroupAni_3E438:   offsetTable                     ; include "mappings/sprite/objC7_c.asm"
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame0
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame1
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame2
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame3
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame4
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame5
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame6
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame7
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame8
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame9
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame10
                    offsetTableEntry.w DeathEggRobot_LimbMotion3_Frame11

DeathEggRobot_LimbMotion3_Frame0:   c7anilistheader $20
                    c7ani   objoff_34, $F8, $F8
                    c7ani   objoff_2E, $F8, $F8
                    c7ani   $00, $00, $FC
                    c7ani   objoff_30, $04, $FB
                    c7ani   objoff_32, $03, $FB
                    c7ani   objoff_3C, $FC, $FB
                    c7ani   objoff_3E, $00, $FE
DeathEggRobot_LimbMotion3_Frame0_End
                    even
DeathEggRobot_LimbMotion3_Frame1:   c7anilistheader $10
                    c7ani   objoff_34, $F0, $FC
                    c7ani   objoff_2E, $F0, $FC
                    c7ani   $00, $F0, $FC
                    c7ani   objoff_30, $F4, $FB
                    c7ani   objoff_32, $F3, $FB
                    c7ani   objoff_3C, $EC, $FB
                    c7ani   objoff_3E, $F8, $00
DeathEggRobot_LimbMotion3_Frame1_End
                    even
DeathEggRobot_LimbMotion3_Frame2:   c7anilistheader $10
                    c7ani   objoff_34, $F8, $04
                    c7ani   objoff_2E, $F8, $04
                    c7ani   $00, $F8, $04
                    c7ani   objoff_30, $FC, $03
                    c7ani   objoff_32, $FB, $03
                    c7ani   objoff_3C, $F4, $03
DeathEggRobot_LimbMotion3_Frame2_End

DeathEggRobot_LimbMotion3_Frame3:   c7anilistheader $10
                    c7ani   objoff_34, $FC, $10
                    c7ani   objoff_2E, $F8, $10
                    c7ani   $00, $00, $08
                    c7ani   objoff_30, $F8, $0A
                    c7ani   objoff_32, $FA, $0A
                    c7ani   objoff_3C, $08, $0A
                    c7ani   objoff_3E, $00, $08
DeathEggRobot_LimbMotion3_Frame3_End
                    even
DeathEggRobot_LimbMotion3_Frame4:   c7anilistheader $20
                    c7ani   objoff_34, $FE, $FE
                    c7ani   $00, $F4, $FC
                    c7ani   objoff_30, $F0, $FD
                    c7ani   objoff_32, $F1, $FD
                    c7ani   objoff_3C, $F8, $FD
                    c7ani   objoff_3E, $EC, $FA
                    c7ani   objoff_3A, $E8, $FC
DeathEggRobot_LimbMotion3_Frame4_End
                    even
DeathEggRobot_LimbMotion3_Frame5:   c7anilistheader $20
                    c7ani   objoff_3E, $F8, $FC
                    c7ani   objoff_3A, $F8, $FC
                    c7ani   objoff_30, $FC, $FF
                    c7ani   objoff_32, $FD, $FF
                    c7ani   objoff_3C, $04, $FF
DeathEggRobot_LimbMotion3_Frame5_End
                    even
DeathEggRobot_LimbMotion3_Frame6:   c7anilistheader $10
                    c7ani   objoff_3E, $F0, $FC
                    c7ani   objoff_3A, $F0, $FC
                    c7ani   $00, $F0, $FC
                    c7ani   objoff_30, $EC, $FB
                    c7ani   objoff_32, $ED, $FB
                    c7ani   objoff_3C, $F4, $FB
                    c7ani   objoff_34, $F8, $00
DeathEggRobot_LimbMotion3_Frame6_End
                    even
DeathEggRobot_LimbMotion3_Frame7:   c7anilistheader $10
                    c7ani   objoff_3E, $F8, $04
                    c7ani   objoff_3A, $F8, $04
                    c7ani   $00, $F8, $04
                    c7ani   objoff_30, $F4, $03
                    c7ani   objoff_32, $F5, $03
                    c7ani   objoff_3C, $FC, $03
DeathEggRobot_LimbMotion3_Frame7_End

DeathEggRobot_LimbMotion3_Frame8:   c7anilistheader $10
                    c7ani   objoff_3E, $FC, $10
                    c7ani   objoff_3A, $F8, $10
                    c7ani   $00, $00, $08
                    c7ani   objoff_30, $08, $0A
                    c7ani   objoff_32, $06, $0A
                    c7ani   objoff_3C, $F8, $0A
                    c7ani   objoff_34, $00, $08
DeathEggRobot_LimbMotion3_Frame8_End
                    even
DeathEggRobot_LimbMotion3_Frame9:   c7anilistheader $20
                    c7ani   objoff_3E, $FE, $FE
                    c7ani   $00, $F4, $FC
                    c7ani   objoff_30, $F8, $FD
                    c7ani   objoff_32, $F7, $FD
                    c7ani   objoff_3C, $F1, $FD
                    c7ani   objoff_34, $EC, $FA
                    c7ani   objoff_2E, $E8, $FC
DeathEggRobot_LimbMotion3_Frame9_End
                    even
DeathEggRobot_LimbMotion3_Frame10:  c7anilistheader $20
                    c7ani   objoff_34, $F8, $FC
                    c7ani   objoff_2E, $F8, $FC
                    c7ani   objoff_30, $04, $FF
                    c7ani   objoff_32, $03, $FF
                    c7ani   objoff_3C, $FC, $FF
DeathEggRobot_LimbMotion3_Frame10_End
                    even
DeathEggRobot_LimbMotion3_Frame11:  c7anilistheader $10
                    c7ani   objoff_3E, $00, $08
                    c7ani   objoff_3A, $00, $08
                    c7ani   $00, $00, $08
                    c7ani   objoff_30, $00, $08
                    c7ani   objoff_32, $00, $08
                    c7ani   objoff_3C, $00, $08
                    c7ani   objoff_34, $00, $08
DeathEggRobot_LimbMotion3_Frame11_End
                    even

; word_3E55C
ChildObjC7_Shoulder:
                    dc.w    objoff_2C
                    dc.b    ObjID_Eggrobo
                    dc.b    4
; word_3E560
ChildObjC7_FrontLowerLeg:
                    dc.w    objoff_2E
                    dc.b    ObjID_Eggrobo
                    dc.b    6
; word_3E564
ChildObjC7_FrontForearm:
                    dc.w    objoff_30
                    dc.b    ObjID_Eggrobo
                    dc.b    8
; word_3E568
ChildObjC7_Arm:
                    dc.w    objoff_32
                    dc.b    ObjID_Eggrobo
                    dc.b    $A
; word_3E56C
ChildObjC7_FrontThigh:
                    dc.w    objoff_34
                    dc.b    ObjID_Eggrobo
                    dc.b    $C
; word_3E570
ChildObjC7_Head:
                    dc.w    objoff_36
                    dc.b    ObjID_Eggrobo
                    dc.b    $E
; word_3E574
ChildObjC7_Jet:
                    dc.w    objoff_38
                    dc.b    ObjID_Eggrobo
                    dc.b    $10
; word_3E578
ChildObjC7_BackLowerLeg:
                    dc.w    objoff_3A
                    dc.b    ObjID_Eggrobo
                    dc.b    $12
; word_3E57C
ChildObjC7_BackForearm:
                    dc.w    objoff_3C
                    dc.b    ObjID_Eggrobo
                    dc.b    $14
; word_3E580
ChildObjC7_BackThigh:
                    dc.w    objoff_3E
                    dc.b    ObjID_Eggrobo
                    dc.b    $16
; word_3E584
ChildObjC7_TargettingSensor:
                    dc.w    objoff_10
                    dc.b    ObjID_Eggrobo
                    dc.b    $18
; word_3E588
ChildObjC7_TargettingLock:
                    dc.w    objoff_10
                    dc.b    ObjID_Eggrobo
                    dc.b    $1A
; word_3E58C
ChildObjC7_EggmanBomb:
                    dc.w    objoff_10
                    dc.b    ObjID_Eggrobo
                    dc.b    $1C
; off_3E590
ObjC7_SubObjData:
                    subObjData ObjC7_MapUnc_3E5F8,make_art_tile(ArtTile_ArtNem_DEZBoss,0,0),1<<render_flags.level_fg,4,$38,$00

; animation script
; off_3E59A:
Ani_objC7_a:    offsetTable
                    offsetTableEntry.w +
+               dc.b    7,$15,$15,$15,$15,$15,$15,$15,$15,  0,  1,  2,$FA
                    even

; animation script
; off_3E5AA:
Ani_objC7_b:    offsetTable
                    offsetTableEntry.w DeathEggRobotBoss_Animation_Sequence0
                    offsetTableEntry.w DeathEggRobotBoss_Animation_Sequence1
                    offsetTableEntry.w DeathEggRobotBoss_Animation_Sequence2
                    offsetTableEntry.w DeathEggRobotBoss_Animation_Sequence3
DeathEggRobotBoss_Animation_Sequence0:  dc.b    1, $C, $D,$FF
DeathEggRobotBoss_Animation_Sequence1:  dc.b    1, $C, $D, $C, $C, $D, $D, $C, $C, $C, $D, $D, $D, $C, $C, $C
                    dc.b    $C, $C, $D, $D, $D, $D, $D, $D,$FA,  0  ; 16
DeathEggRobotBoss_Animation_Sequence2:  dc.b    1, $D, $D, $D, $D, $D, $D, $C, $C, $C, $C, $C, $D, $D, $D, $C
                    dc.b    $C, $C, $D, $D, $C, $C, $D, $C,$FD,  0  ; 16
DeathEggRobotBoss_Animation_Sequence3:  dc.b    0, $D,$15,$FF
                    even

; animation script
; off_3E5EE:
Ani_objC7_c:    offsetTable
                    offsetTableEntry.w DeathEggRobot_AnimSeq0_Variant2
DeathEggRobot_AnimSeq0_Variant2:    dc.b    3,$13,$12,$11,$10,$16,$FF
                    even
; ------------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------------
ObjC7_MapUnc_3E5F8: include "src/game/objects/bosses/death_egg_robot/mappings.s"
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to upscale graphics by a factor of 2x, based on given mappings
; data for correct positioning of tiles
;
; This code is awfully structured and planned: whenever a 3-column sprite piece
; is scaled, it scales the next tiles that were copied to RAM as if the piece
; had 4 columns; this will then be promptly overwritten by the next piece. If
; this happens near the end of the buffer, you will get a buffer overrun
; Moreover, when the number of rows in the sprite piece is also 3 or 4, the code
; will make an incorrect computation for the output of the next subpiece, which
; causes the output to overwrite art from the previous subpiece. Thus, this code
; fails if there is a 3x3 or a 3x4 sprite piece in the source mappings. Sadly,
; this issue is basically unfixable without rewriting the code entirely
;
; Input:
; a1 Location of tiles to be enlarged
; a2 Destination buffer for enlarged tiles
; d0 Width-1 of sprite piece
; d1 Height-1 of sprite piece
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_3E89E
