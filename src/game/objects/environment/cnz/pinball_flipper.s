Obj86:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj86_Index(pc,d0.w),d1
                jsr     Obj86_Index(pc,d1.w)
                jmpto   JmpTo27_MarkObjGone
; ===========================================================================
; off_2B152:
Obj86_Index:    offsetTable
                offsetTableEntry.w Obj86_Init           ; 0
                offsetTableEntry.w Obj86_UpwardsType    ; 2 - sends you upwards
                offsetTableEntry.w Obj86_HorizontalType  ; 4 - sends you leftward/rightward
; ===========================================================================
; loc_2B158:
Obj86_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj86_MapUnc_2B45A,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_CNZFlipper,2,0),art_tile(a0)
                jsrto   JmpTo50_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$18,width_pixels(a0)
                move.b  #4,priority(a0)
                tst.b   subtype(a0)
                beq.s   Obj86_UpwardsType
                addq.b  #2,routine(a0)
                move.b  #2,anim(a0)
                bra.w   Obj86_HorizontalType
; ===========================================================================
; loc_2B194:
Obj86_UpwardsType:
                tst.w   (Debug_placement_mode).w
                bne.s   CnzPinballFlipper_Return
                lea     (byte_2B3C6).l,a2
                move.b  mapping_frame(a0),d0
                beq.s   loc_2B1B6
                lea     (byte_2B3EA).l,a2
                subq.b  #1,d0
                beq.s   loc_2B1B6
                lea     (byte_2B40E).l,a2

loc_2B1B6:
                move.w  #$23,d1
                move.w  #6,d2
                move.w  x_pos(a0),d4
                jsrto   JmpTo2_SlopedSolid
                lea     objoff_36(a0),a3
                lea     (MainCharacter).w,a1            ; a1=character
                move.w  (Ctrl_1_Logical).w,d5
                moveq   #p1_standing_bit,d6
                bsr.s   CnzFlipper_UpdatePlayerControl
                addq.w  #1,a3
                lea     (Sidekick).w,a1                 ; a1=character
                move.w  (Ctrl_2).w,d5
                moveq   #p2_standing_bit,d6
                bsr.s   CnzFlipper_UpdatePlayerControl
                tst.b   objoff_38(a0)
                beq.s   loc_2B1FE
                clr.b   objoff_38(a0)
                bsr.w   CnzFlipper_ReleaseStandingPlayer
                subq.w  #1,a3
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                bsr.w   CnzFlipper_ReleaseStandingPlayer

loc_2B1FE:
                lea     (Ani_obj86).l,a1
                jmpto   JmpTo9_AnimateSprite
; ===========================================================================

CnzPinballFlipper_Return:
                rts
; ===========================================================================

CnzFlipper_UpdatePlayerControl:
                move.b  (a3),d0
                bne.s   loc_2B23C
                btst    d6,status(a0)
                beq.s   CnzPinballFlipper_Return
                move.b  #1,obj_control(a1)
                move.b  #$E,y_radius(a1)
                move.b  #7,x_radius(a1)
                move.b  #AniIDSonAni_Roll,anim(a1)
                bset    #status.player.rolling,status(a1)
                bne.s   loc_2B238
                addq.w  #5,y_pos(a1)

loc_2B238:
                addq.b  #1,(a3)
                rts
; ===========================================================================

loc_2B23C:
                andi.w  #button_B_mask|button_C_mask|button_A_mask,d5
                bne.s   loc_2B288
                btst    d6,status(a0)
                bne.s   loc_2B254
                move.b  #0,obj_control(a1)
                move.b  #0,(a3)
                rts
; ===========================================================================

loc_2B254:
                moveq   #0,d1
                move.b  mapping_frame(a0),d1
                subq.w  #1,d1
                bset    #status.player.x_flip,status(a1)
                btst    #status.npc.x_flip,status(a0)
                bne.s   loc_2B272
                neg.w   d1
                bclr    #status.player.x_flip,status(a1)

loc_2B272:
                add.w   d1,x_pos(a1)
                lsl.w   #8,d1
                move.w  d1,x_vel(a1)
                move.w  d1,inertia(a1)
                move.w  #0,y_vel(a1)
                rts
; ===========================================================================

loc_2B288:
                move.b  #1,objoff_38(a0)
                rts
; ===========================================================================

CnzFlipper_ReleaseStandingPlayer:
                bclr    d6,status(a0)
                beq.w   CnzPinballFlipper_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                btst    #status.npc.x_flip,status(a0)
                beq.s   loc_2B2AA
                neg.w   d0

loc_2B2AA:
                addi.w  #$23,d0
                move.w  d0,d2
                cmpi.w  #$40,d2
                blo.s   loc_2B2BA
                move.w  #$40,d2

loc_2B2BA:
                lsl.w   #5,d2
                addi.w  #$800,d2
                neg.w   d2
                asr.w   #2,d0
                addi.w  #$40,d0
                jsrto   JmpTo11_CalcSine
                muls.w  d2,d0
                muls.w  d2,d1
                asr.l   #8,d0
                asr.l   #8,d1
                move.w  d0,y_vel(a1)
                btst    #status.npc.x_flip,status(a0)
                beq.s   loc_2B2E2
                neg.w   d1

loc_2B2E2:
                move.w  d1,x_vel(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #status.player.on_object,status(a1)
                move.b  #2,routine(a1)
                move.b  #0,obj_control(a1)
                move.b  #1,anim(a0)
                move.b  #0,(a3)
                move.w  #SndID_Flipper,d0
                jmp     (PlaySound).l
; ===========================================================================
; loc_2B312:
Obj86_HorizontalType:
                move.w  #$13,d1
                move.w  #$18,d2
                move.w  #$19,d3
                move.w  x_pos(a0),d4
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                movem.l d1-d4,-(sp)
                jsrto   JmpTo6_SolidObject_Always_SingleCharacter
                btst    #p1_pushing_bit,status(a0)
                beq.s   loc_2B33A
                bsr.s   CnzFlipper_LaunchPlayerHorizontally

loc_2B33A:
                movem.l (sp)+,d1-d4
                lea     (Sidekick).w,a1                 ; a1=character
                moveq   #p2_standing_bit,d6
                jsrto   JmpTo6_SolidObject_Always_SingleCharacter
                btst    #p2_pushing_bit,status(a0)
                beq.s   loc_2B352
                bsr.s   CnzFlipper_LaunchPlayerHorizontally

loc_2B352:
                lea     (Ani_obj86).l,a1
                jmpto   JmpTo9_AnimateSprite
; ===========================================================================

CnzFlipper_LaunchPlayerHorizontally:
                move.w  #(3<<8)|(0<<0),anim(a0)
                move.w  #-$1000,x_vel(a1)
                addq.w  #8,x_pos(a1)
                bset    #status.player.x_flip,status(a1)
                move.w  x_pos(a0),d0
                sub.w   x_pos(a1),d0
                bcc.s   loc_2B392
                bclr    #status.player.x_flip,status(a1)
                subi.w  #$10,x_pos(a1)
                neg.w   x_vel(a1)
                move.w  #(4<<8)|(0<<0),anim(a0)

loc_2B392:
                move.w  #$F,move_lock(a1)
                move.w  x_vel(a1),inertia(a1)
                move.b  #$E,y_radius(a1)
                move.b  #7,x_radius(a1)
                move.b  #AniIDSonAni_Roll,anim(a1)
                bset    #status.player.rolling,status(a1)
                bne.s   loc_2B3BC
                addq.w  #5,y_pos(a1)

loc_2B3BC:
                move.w  #SndID_Flipper,d0
                jmp     (PlaySound).l
; ===========================================================================
byte_2B3C6:
                dc.b    7,  7,  7,  7,  7,  7,  7,  8,  9, $A, $B, $A,  9,  8,  7,  6
                dc.b    5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7, -8, -9,-$A  ; 16
                dc.b    -$B,-$C,-$D,-$E                 ; 32
byte_2B3EA:
                dc.b    6,  6,  6,  6,  6,  6,  7,  8,  9,  9,  9,  9,  9,  9,  8,  8
                dc.b    8,  8,  8,  8,  7,  7,  7,  7,  6,  6,  6,  6,  5,  5,  4,  4  ; 16
                dc.b    4,  4,  4,  4                   ; 32
byte_2B40E:
                dc.b    5,  5,  5,  5,  5,  6,  7,  8,  9, $A, $B, $B, $C, $C, $D, $D
                dc.b    $E, $E, $F, $F,$10,$10,$11,$11,$12,$12,$11,$11,$10,$10,$10,$10  ; 16
                dc.b    $10,$10,$10,$10                 ; 32
                even

; animation script
; off_2B432:
Ani_obj86:      offsetTable
                offsetTableEntry.w CnzPinballFlipper_Animation_Sequence0  ; 0
                offsetTableEntry.w CnzPinballFlipper_Animation_Sequence1  ; 1
                offsetTableEntry.w CnzPinballFlipper_Animation_Sequence2  ; 2
                offsetTableEntry.w CnzPinballFlipper_Animation_Sequence3  ; 3
                offsetTableEntry.w CnzPinballFlipper_Animation_Sequence4  ; 4
CnzPinballFlipper_Animation_Sequence0:  dc.b    $F,  0,$FF
CnzPinballFlipper_Animation_Sequence1:  dc.b    3,  1,  2,  1,$FD,  0
CnzPinballFlipper_Animation_Sequence2:  dc.b    $F,  4,$FF
CnzPinballFlipper_Animation_Sequence3:  dc.b    0,  5,  4,  3,  3,  3,  3,$FD,  2
CnzPinballFlipper_Animation_Sequence4:  dc.b    0,  3,  4,  5,  5,  5,  5,$FD,  2
                even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj86_MapUnc_2B45A:
Map_obj86:      mappingsTable
                mappingsTableEntry.w Map_obj86_000C
                mappingsTableEntry.w Map_obj86_0026
                mappingsTableEntry.w Map_obj86_0038
                mappingsTableEntry.w Map_obj86_0052
                mappingsTableEntry.w Map_obj86_006C
                mappingsTableEntry.w Map_obj86_008E

Map_obj86_000C: spriteHeader
                spritePiece -$19, -9, 3, 4, $C, 0, 0, 0, 0
                spritePiece -1, -2, 1, 2, $18, 0, 0, 0, 0
                spritePiece 7, 1, 2, 2, $1A, 0, 0, 0, 0
Map_obj86_000C_End

Map_obj86_0026: spriteHeader
                spritePiece -$18, -8, 4, 2, 0, 0, 0, 0, 0
                spritePiece 8, -8, 2, 2, 8, 0, 0, 0, 0
Map_obj86_0026_End

Map_obj86_0038: spriteHeader
                spritePiece -$19, -$17, 3, 4, $C, 0, 1, 0, 0
                spritePiece -1, -$E, 1, 2, $18, 0, 1, 0, 0
                spritePiece 7, -$11, 2, 2, $1A, 0, 1, 0, 0
Map_obj86_0038_End

Map_obj86_0052: spriteHeader
                spritePiece -$F, -$19, 3, 2, $24, 0, 0, 0, 0
                spritePiece -$11, -9, 3, 2, $2A, 0, 0, 0, 0
                spritePiece -$11, 7, 2, 2, $30, 0, 0, 0, 0
Map_obj86_0052_End

Map_obj86_006C: spriteHeader
                spritePiece -8, -$18, 1, 4, $1E, 0, 0, 0, 0
                spritePiece 0, -$18, 1, 4, $1E, 1, 0, 0, 0
                spritePiece -8, 8, 1, 2, $22, 0, 0, 0, 0
                spritePiece 0, 8, 1, 2, $22, 1, 0, 0, 0
Map_obj86_006C_End

Map_obj86_008E: spriteHeader
                spritePiece -9, -$19, 3, 2, $24, 1, 0, 0, 0
                spritePiece -7, -9, 3, 2, $2A, 1, 0, 0, 0
                spritePiece 1, 7, 2, 2, $30, 1, 0, 0, 0
Map_obj86_008E_End

                even
; ===========================================================================

                jmpTos  JmpTo27_MarkObjGone,JmpTo9_AnimateSprite,JmpTo50_Adjust2PArtPointer,JmpTo11_CalcSine,JmpTo6_SolidObject_Always_SingleCharacter,JmpTo2_SlopedSolid

; ===========================================================================
; ---------------------------------------------------------------------------
; Object D2 - Flashing blocks that appear and disappear in a rectangular shape that you can walk across, from CNZ
; ---------------------------------------------------------------------------
; Sprite_2B528:
