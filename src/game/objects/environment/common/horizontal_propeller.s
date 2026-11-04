ObjB5:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjB5_Index(pc,d0.w),d1
                jmp     ObjB5_Index(pc,d1.w)
; ===========================================================================
; off_3B408:
ObjB5_Index:    offsetTable
                offsetTableEntry.w ObjB5_Init           ; 0
                offsetTableEntry.w ObjB5_Main           ; 2 - used in WFZ
                offsetTableEntry.w ObjB5_Animate        ; 4 - used in SCZ, no effect on players
; ===========================================================================
; loc_3B40E:
ObjB5_Init:
                bsr.w   LoadSubObject
                move.b  #4,anim(a0)
                move.b  subtype(a0),d0
                subi.b  #$64,d0
                move.b  d0,routine(a0)
                rts
; ===========================================================================
; loc_3B426:
ObjB5_Main:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3B442(pc,d0.w),d1
                jsr     off_3B442(pc,d1.w)
                lea     (Ani_objB5).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
off_3B442:      offsetTable
                offsetTableEntry.w +                    ; 0
; ===========================================================================
+               bra.w   ObjB5_CheckPlayers
; ===========================================================================
; loc_3B448:
ObjB5_Animate:
                lea     (Ani_objB5).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
; loc_3B456:
ObjB5_CheckPlayers:
                cmpi.b  #4,anim(a0)
                bne.s   ++                              ; rts
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.w   ObjB5_CheckPlayer
                lea     (Sidekick).w,a1                 ; a1=character
; loc_3B46A:
ObjB5_CheckPlayer:
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                addi.w  #$40,d0
                cmpi.w  #$80,d0
                bhs.s   ++                              ; rts
                moveq   #0,d1
                move.b  (Oscillating_Data+$14).w,d1
                add.w   y_pos(a1),d1
                addi.w  #$60,d1
                sub.w   y_pos(a0),d1
                bcs.s   ++                              ; rts
                cmpi.w  #$90,d1
                bhs.s   ++                              ; rts
                subi.w  #$60,d1
                bcs.s   +
                not.w   d1
                add.w   d1,d1
+
                addi.w  #$60,d1
                neg.w   d1
                asr.w   #4,d1
                add.w   d1,y_pos(a1)
                bset    #status.player.in_air,status(a1)
                move.w  #0,y_vel(a1)
                move.w  #1,inertia(a1)
                tst.b   flip_angle(a1)
                bne.s   +                               ; rts
                move.b  #1,flip_angle(a1)
                move.b  #AniIDSonAni_Float2,anim(a1)
                move.b  #$7F,flips_remaining(a1)
                move.b  #8,flip_speed(a1)
+
                rts
; ===========================================================================
; off_3B4DE:
ObjB5_SubObjData:
                subObjData ObjB5_MapUnc_3B548,make_art_tile(ArtTile_ArtNem_WfzHrzntlPrpllr,1,1),1<<render_flags.level_fg,4,$40,0

; animation script
; off_3B4E8:
Ani_objB5:      offsetTable
                offsetTableEntry.w HorizontalPropeller_AnimSeq0  ; 0
                offsetTableEntry.w HorizontalPropeller_AnimSeq1  ; 1
                offsetTableEntry.w HorizontalPropeller_AnimSeq2  ; 2
                offsetTableEntry.w HorizontalPropeller_AnimSeq3  ; 3
                offsetTableEntry.w HorizontalPropeller_AnimSeq4  ; 4
                offsetTableEntry.w HorizontalPropeller_AnimSeq5  ; 5
                offsetTableEntry.w HorizontalPropeller_AnimSeq6  ; 6
                offsetTableEntry.w HorizontalPropeller_AnimSeq7  ; 7
                offsetTableEntry.w HorizontalPropeller_AnimSeq8  ; 8
                offsetTableEntry.w HorizontalPropeller_AnimSeq9  ; 9
HorizontalPropeller_AnimSeq0:   dc.b    7,  0,  1,  2,  3,  4,  5,$FD,  1,  0
HorizontalPropeller_AnimSeq1:   dc.b    4,  0,  1,  2,  3,  4,$FD,  2
HorizontalPropeller_AnimSeq2:   dc.b    3,  5,  0,  1,  2,$FD,  3,  0
HorizontalPropeller_AnimSeq3:   dc.b    2,  3,  4,  5,$FD,  4
HorizontalPropeller_AnimSeq4:   dc.b    1,  0,  1,  2,  3,  4,  5,$FF
HorizontalPropeller_AnimSeq5:   dc.b    2,  5,  4,  3,$FD,  6
HorizontalPropeller_AnimSeq6:   dc.b    3,  2,  1,  0,  5,$FD,  7,  0
HorizontalPropeller_AnimSeq7:   dc.b    4,  4,  3,  2,  1,  0,$FD,  8
HorizontalPropeller_AnimSeq8:   dc.b    7,  5,  4,  3,  2,  1,  0,$FD,  9,  0
HorizontalPropeller_AnimSeq9:   dc.b    $7E,  0,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB5_MapUnc_3B548:
Map_objB5:      mappingsTable
                mappingsTableEntry.w Map_objB5_000C
                mappingsTableEntry.w Map_objB5_002E
                mappingsTableEntry.w Map_objB5_0040
                mappingsTableEntry.w Map_objB5_0052
                mappingsTableEntry.w Map_objB5_0064
                mappingsTableEntry.w Map_objB5_0076

Map_objB5_000C: spriteHeader
                spritePiece -$40, -4, 4, 1, 0, 0, 0, 0, 0
                spritePiece -$20, -4, 3, 1, 4, 0, 0, 0, 0
                spritePiece 8, -4, 3, 1, 7, 0, 0, 0, 0
                spritePiece $20, -4, 4, 1, $A, 0, 0, 0, 0
Map_objB5_000C_End

Map_objB5_002E: spriteHeader
                spritePiece -$28, -4, 4, 1, $E, 0, 0, 0, 0
                spritePiece 8, -4, 4, 1, $12, 0, 0, 0, 0
Map_objB5_002E_End

Map_objB5_0040: spriteHeader
                spritePiece -$18, -4, 3, 1, $16, 0, 0, 0, 0
                spritePiece 8, -4, 2, 1, $19, 0, 0, 0, 0
Map_objB5_0040_End

Map_objB5_0052: spriteHeader
                spritePiece -$10, -4, 2, 1, $1B, 0, 0, 0, 0
                spritePiece 0, -4, 2, 1, $1B, 1, 0, 0, 0
Map_objB5_0052_End

Map_objB5_0064: spriteHeader
                spritePiece -$18, -4, 2, 1, $19, 1, 0, 0, 0
                spritePiece 0, -4, 3, 1, $16, 1, 0, 0, 0
Map_objB5_0064_End

Map_objB5_0076: spriteHeader
                spritePiece -$28, -4, 4, 1, $12, 1, 0, 0, 0
                spritePiece 8, -4, 4, 1, $E, 1, 0, 0, 0
Map_objB5_0076_End

                even
; ===========================================================================
; ----------------------------------------------------------------------------
; Object B6 - Tilting platform from WFZ
; ----------------------------------------------------------------------------
; Sprite_3B5D0:
