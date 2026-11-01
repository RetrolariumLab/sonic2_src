Obj24:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj24_Index(pc,d0.w),d1
                jmp     Obj24_Index(pc,d1.w)
; ===========================================================================
; off_1F8B6:
Obj24_Index:    offsetTable
                offsetTableEntry.w Obj24_Init           ; 0
                offsetTableEntry.w loc_1F924            ; 2
                offsetTableEntry.w loc_1F93E            ; 4
                offsetTableEntry.w loc_1F99E            ; 6
                offsetTableEntry.w BranchTo_JmpTo15_DeleteObject  ; 8
                offsetTableEntry.w loc_1F9C0            ; $A
; ===========================================================================
; loc_1F8C2:
Obj24_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj24_MapUnc_1FBF6,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_BigBubbles,0,1),art_tile(a0)
                jsrto   JmpTo6_Adjust2PArtPointer
                move.b  #1<<render_flags.on_screen|1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #1,priority(a0)
                move.b  subtype(a0),d0
                bpl.s   loc_1F90A
                addq.b  #8,routine(a0)
                andi.w  #$7F,d0
                move.b  d0,objoff_32(a0)
                move.b  d0,objoff_33(a0)
                move.b  #6,anim(a0)
                bra.w   loc_1F9C0
; ===========================================================================

loc_1F90A:
                move.b  d0,anim(a0)
                move.w  x_pos(a0),objoff_30(a0)
                move.w  #-$88,y_vel(a0)
                jsr     (RandomNumber).l
                move.b  d0,angle(a0)

loc_1F924:
                lea     (Ani_obj24).l,a1
                jsr     (AnimateSprite).l
                cmpi.b  #6,mapping_frame(a0)
                bne.s   loc_1F93E
                move.b  #1,objoff_2E(a0)

loc_1F93E:

                move.w  (Water_Level_1).w,d0
                cmp.w   y_pos(a0),d0
                blo.s   loc_1F956
                move.b  #6,routine(a0)
                addq.b  #3,anim(a0)
                bra.w   loc_1F99E
; ===========================================================================

loc_1F956:
                move.b  angle(a0),d0
                addq.b  #1,angle(a0)
                andi.w  #$7F,d0
                lea     (Obj0A_WobbleData).l,a1
                move.b  (a1,d0.w),d0
                ext.w   d0
                add.w   objoff_30(a0),d0
                move.w  d0,x_pos(a0)
                tst.b   objoff_2E(a0)
                beq.s   loc_1F988
                bsr.w   ArzBubble_CheckBothPlayers
                cmpi.b  #6,routine(a0)
                beq.s   loc_1F99E

loc_1F988:
                jsrto   JmpTo3_ObjectMove
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  JmpTo13_DeleteObject
                jmp     (DisplaySprite).l
; ===========================================================================

JmpTo13_DeleteObject                                    ; JmpTo
                jmp     (DeleteObject).l
; ===========================================================================

loc_1F99E:

                lea     (Ani_obj24).l,a1
                jsr     (AnimateSprite).l
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  JmpTo14_DeleteObject
                jmp     (DisplaySprite).l
; ===========================================================================

JmpTo14_DeleteObject                                    ; JmpTo
                jmp     (DeleteObject).l
; ===========================================================================

BranchTo_JmpTo15_DeleteObject                           ; BranchTo
                jmpto   JmpTo15_DeleteObject
; ===========================================================================

loc_1F9C0:

                tst.w   objoff_36(a0)
                bne.s   loc_1FA22
                move.w  (Water_Level_1).w,d0
                cmp.w   y_pos(a0),d0
                bhs.w   loc_1FACE
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.w  loc_1FACE
                subq.w  #1,objoff_38(a0)
                bpl.w   loc_1FAC2
                move.w  #1,objoff_36(a0)

loc_1F9E8:
                jsr     (RandomNumber).l
                move.w  d0,d1
                andi.w  #7,d0
                cmpi.w  #6,d0
                bhs.s   loc_1F9E8
                move.b  d0,objoff_34(a0)
                andi.w  #$C,d1
                lea     (byte_1FAF0).l,a1
                adda.w  d1,a1
                move.l  a1,objoff_3C(a0)
                subq.b  #1,objoff_32(a0)
                bpl.s   BranchTo_loc_1FA2A
                move.b  objoff_33(a0),objoff_32(a0)
                bset    #7,objoff_36(a0)

BranchTo_loc_1FA2A                                      ; BranchTo
                bra.s   loc_1FA2A
; ===========================================================================

loc_1FA22:
                subq.w  #1,objoff_38(a0)
                bpl.w   loc_1FAC2

loc_1FA2A:
                jsr     (RandomNumber).l
                andi.w  #$1F,d0
                move.w  d0,objoff_38(a0)
                bsr.w   AllocateObject
                bne.s   loc_1FAA6
                _move.b id(a0),id(a1)                   ; load obj24
                move.w  x_pos(a0),x_pos(a1)
                jsr     (RandomNumber).l
                andi.w  #$F,d0
                subq.w  #8,d0
                add.w   d0,x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                moveq   #0,d0
                move.b  objoff_34(a0),d0
                movea.l objoff_3C(a0),a2                ; a2=object
                move.b  (a2,d0.w),subtype(a1)
                btst    #7,objoff_36(a0)
                beq.s   loc_1FAA6
                jsr     (RandomNumber).l
                andi.w  #3,d0
                bne.s   loc_1FA92
                bset    #6,objoff_36(a0)
                bne.s   loc_1FAA6
                move.b  #2,subtype(a1)

loc_1FA92:
                tst.b   objoff_34(a0)
                bne.s   loc_1FAA6
                bset    #6,objoff_36(a0)
                bne.s   loc_1FAA6
                move.b  #2,subtype(a1)

loc_1FAA6:
                subq.b  #1,objoff_34(a0)
                bpl.s   loc_1FAC2
                jsr     (RandomNumber).l
                andi.w  #$7F,d0
                addi.w  #$80,d0
                add.w   d0,objoff_38(a0)
                clr.w   objoff_36(a0)

loc_1FAC2:
                lea     (Ani_obj24).l,a1
                jsr     (AnimateSprite).l

loc_1FACE:
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   JmpTo15_DeleteObject
                move.w  (Water_Level_1).w,d0
                cmp.w   y_pos(a0),d0
                blo.w   JmpTo7_DisplaySprite
                rts

; ===========================================================================
byte_1FAF0:
                dc.b    0
                dc.b    1                               ; 1
                dc.b    0                               ; 2
                dc.b    0                               ; 3
                dc.b    0                               ; 4
                dc.b    0                               ; 5
                dc.b    1                               ; 6
                dc.b    0                               ; 7
                dc.b    0                               ; 8
                dc.b    0                               ; 9
                dc.b    0                               ; 10
                dc.b    1                               ; 11
                dc.b    0                               ; 12
                dc.b    1                               ; 13
                dc.b    0                               ; 14
                dc.b    0                               ; 15
                dc.b    1                               ; 16
                dc.b    0                               ; 17
                even
; ===========================================================================

ArzBubble_CheckBothPlayers:
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.s   ArzBubble_HandlePlayerInhale
                lea     (Sidekick).w,a1                 ; a1=character

ArzBubble_HandlePlayerInhale:
                tst.b   obj_control(a1)
                bmi.w   ArzBubbles_Return
                move.w  x_pos(a1),d0
                move.w  x_pos(a0),d1
                subi.w  #$10,d1
                cmp.w   d0,d1
                bhs.w   ArzBubbles_Return
                addi.w  #$20,d1
                cmp.w   d0,d1
                blo.w   ArzBubbles_Return
                move.w  y_pos(a1),d0
                move.w  y_pos(a0),d1
                cmp.w   d0,d1
                bhs.w   ArzBubbles_Return
                addi.w  #$10,d1
                cmp.w   d0,d1
                blo.w   ArzBubbles_Return
                bsr.w   ResumeMusic
                move.w  #SndID_InhalingBubble,d0
                jsr     (PlaySound).l
                clr.w   x_vel(a1)
                clr.w   y_vel(a1)
                clr.w   inertia(a1)
                move.b  #AniIDSonAni_Bubble,anim(a1)
                move.w  #$23,move_lock(a1)
                move.b  #0,jumping(a1)
                bclr    #status.player.pushing,status(a1)
                bclr    #status.player.rolljumping,status(a1)
                btst    #status.player.rolling,status(a1)
                beq.w   loc_1FBB8
                cmpi.b  #1,(a1)
                bne.s   loc_1FBA8
                bclr    #status.player.rolling,status(a1)
                move.b  #$13,y_radius(a1)
                move.b  #9,x_radius(a1)
                subq.w  #5,y_pos(a1)
                bra.s   loc_1FBB8
; ===========================================================================

loc_1FBA8:
                move.b  #$F,y_radius(a1)
                move.b  #9,x_radius(a1)
                subq.w  #1,y_pos(a1)

loc_1FBB8:
                cmpi.b  #6,routine(a0)
                beq.s   ArzBubbles_Return
                move.b  #6,routine(a0)
                addq.b  #3,anim(a0)

ArzBubbles_Return:
                rts
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite animations
; -------------------------------------------------------------------------------
; animation script
; off_1FBCC:
Ani_obj24:      offsetTable
                offsetTableEntry.w ArzBubbles_Animation_Sequence0           ; 0
                offsetTableEntry.w ArzBubbles_Animation_Sequence1           ; 1
                offsetTableEntry.w ArzBubbles_Animation_Sequence2           ; 2
                offsetTableEntry.w ArzBubbles_Animation_Sequence3           ; 3
                offsetTableEntry.w ArzBubbles_Animation_Sequence3           ; 4
                offsetTableEntry.w ArzBubbles_Animation_Sequence5           ; 5
                offsetTableEntry.w ArzBubbles_Animation_Sequence6           ; 6
ArzBubbles_Animation_Sequence0:     dc.b    $E,  0,  1,  2,$FC
ArzBubbles_Animation_Sequence1:     dc.b    $E,  1,  2,  3,  4,$FC
ArzBubbles_Animation_Sequence2:     dc.b    $E,  2,  3,  4,  5,  6,$FC
ArzBubbles_Animation_Sequence3:     dc.b    4,$FC
ArzBubbles_Animation_Sequence5:     dc.b    4,  6,  7,$FC
ArzBubbles_Animation_Sequence6:     dc.b    $F, $E, $F,$FF
                even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj24_MapUnc_1FBF6: mappingsTable
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame0
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame1
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame1
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame3
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame4
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame5
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame6
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame7
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame14
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame15
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame16
; -------------------------------------------------------------------------------
; sprite mappings
; merged with the above mappings, can't split to file in a useful way
; -------------------------------------------------------------------------------
Obj24_MapUnc_1FC18: mappingsTable
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame0
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame1
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame1
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame3
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame4
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame5
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame6
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame7
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame8_Variant2
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame14
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame15
                mappingsTableEntry.w ArzBubbles_SpriteMappings_Frame16

ArzBubbles_SpriteMappings_Frame0:     spriteHeader
                spritePiece -4, -4, 1, 1, $8D, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame0_End

ArzBubbles_SpriteMappings_Frame1:     spriteHeader
                spritePiece -4, -4, 1, 1, $8E, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame1_End

ArzBubbles_SpriteMappings_Frame3:     spriteHeader
                spritePiece -8, -8, 2, 2, $8F, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame3_End

ArzBubbles_SpriteMappings_Frame4:     spriteHeader
                spritePiece -8, -8, 2, 2, $93, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame4_End

ArzBubbles_SpriteMappings_Frame5:     spriteHeader
                spritePiece -$C, -$C, 3, 3, $1C, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame5_End

ArzBubbles_SpriteMappings_Frame6:     spriteHeader
                spritePiece -$10, -$10, 4, 4, 8, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame6_End

ArzBubbles_SpriteMappings_Frame7:     spriteHeader
                spritePiece -$10, -$10, 2, 2, $18, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, $18, 1, 0, 0, 0
                spritePiece -$10, 0, 2, 2, $18, 0, 1, 0, 0
                spritePiece 0, 0, 2, 2, $18, 1, 1, 0, 0
ArzBubbles_SpriteMappings_Frame7_End

ArzBubbles_SpriteMappings_Frame8:     spriteHeader
                spritePiece -8, -$C, 2, 3, $741, 1, 1, 0, 0
ArzBubbles_SpriteMappings_Frame8_End

ArzBubbles_SpriteMappings_Frame14:     spriteHeader
                spritePiece -8, -8, 2, 2, 0, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame14_End

ArzBubbles_SpriteMappings_Frame15:     spriteHeader
                spritePiece -8, -8, 2, 2, 4, 0, 0, 0, 0
ArzBubbles_SpriteMappings_Frame15_End

ArzBubbles_SpriteMappings_Frame16:     spriteHeader
ArzBubbles_SpriteMappings_Frame16_End

ArzBubbles_SpriteMappings_Frame8_Variant2:     spriteHeader
                spritePiece -8, -$C, 2, 3, $731, 1, 1, 0, 0
ArzBubbles_SpriteMappings_Frame8_Variant2_End

                even

; ===========================================================================

                jmpTos  JmpTo7_DisplaySprite,JmpTo15_DeleteObject,JmpTo6_Adjust2PArtPointer,JmpTo3_ObjectMove

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 03 - Collision plane/layer switcher
; ---------------------------------------------------------------------------
; OST Variables:
planeswitch_radius      =       objoff_32               ; word ; half-height of x-switcher or half-width of y-switcher
planeswitch_p1_flag     =       objoff_34               ; byte ; 0 if player 1 is above or left of switcher; 1 if below or to right
planeswitch_p2_flag     =       objoff_35               ; byte ; same as above, but for player 2

; Sprite_1FCDC:
