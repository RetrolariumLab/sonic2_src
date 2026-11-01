Obj2B:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj2B_Index(pc,d0.w),d1
                jmp     Obj2B_Index(pc,d1.w)
; ===========================================================================
; off_25A68:
Obj2B_Index:    offsetTable
                offsetTableEntry.w Obj2B_Init           ; 0
                offsetTableEntry.w Obj2B_Main           ; 2
                offsetTableEntry.w loc_25B8E            ; 4
; ===========================================================================
; loc_25A6E:
Obj2B_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj2B_MapUnc_25C6E,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtKos_LevelArt,1,0),art_tile(a0)
                jsrto   JmpTo25_Adjust2PArtPointer
; This should use the accurate height check and larger size values, since
; right now it vanishes whilst partially on-screen
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #$18,y_radius(a0)
                move.b  #4,priority(a0)
; loc_25A9C:
Obj2B_Main:
                move.w  x_pos(a0),-(sp)
                bsr.w   ArzRisingPillar_DispatchSecondaryState
; Read above
                moveq   #0,d1
                move.b  width_pixels(a0),d1
                addi.w  #$B,d1
                moveq   #0,d2
                move.b  y_radius(a0),d2
                move.w  d2,d3
                addq.w  #1,d3
                move.w  (sp)+,d4
                jsrto   JmpTo8_SolidObject
                move.b  status(a0),d0
                andi.b  #standing_mask,d0
                bne.w   loc_25ACE
                jmpto   JmpTo16_MarkObjGone
; ===========================================================================

loc_25ACE:
                lea     (word_25BBE).l,a4
                lea     (byte_25BB0).l,a2
                addq.b  #7,mapping_frame(a0)
                bsr.w   ArzRisingPillar_CreateSpriteFragments
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                bsr.s   ArzRisingPillar_ReleasePlayerIntoRoll
                lea     (Sidekick).w,a1                 ; a1=character
                addq.b  #1,d6
                bsr.s   ArzRisingPillar_ReleasePlayerIntoRoll
                bra.w   loc_25B8E
; ===========================================================================

ArzRisingPillar_ReleasePlayerIntoRoll:
                bclr    d6,status(a0)
                beq.s   ArzRisingPillar_Return
                bset    #status.player.rolling,status(a1)
                move.b  #$E,y_radius(a1)
                move.b  #7,x_radius(a1)
                move.b  #AniIDSonAni_Roll,anim(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #status.player.on_object,status(a1)
                move.b  #2,routine(a1)

ArzRisingPillar_Return:
                rts
; ===========================================================================

ArzRisingPillar_DispatchSecondaryState:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_25B36(pc,d0.w),d1
                jmp     off_25B36(pc,d1.w)
; ===========================================================================
off_25B36:      offsetTable
                offsetTableEntry.w loc_25B3C            ; 0
                offsetTableEntry.w loc_25B66            ; 2
                offsetTableEntry.w ArzRisingPillar_Return_Variant2  ; 4
; ===========================================================================

loc_25B3C:
                tst.w   (Debug_placement_mode).w
                bne.s   ArzRisingPillar_Return_Variant2
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.s   ArzRisingPillar_CheckPlayerProximity
                lea     (Sidekick).w,a1                 ; a1=character

ArzRisingPillar_CheckPlayerProximity:
                move.w  x_pos(a0),d0
                sub.w   x_pos(a1),d0
                bcc.s   loc_25B58
                neg.w   d0

loc_25B58:
                cmpi.w  #$40,d0
                bhs.s   ArzRisingPillar_Return_Variant2
                move.b  #2,routine_secondary(a0)

ArzRisingPillar_Return_Variant2:

                rts
; ===========================================================================

loc_25B66:
                subq.w  #1,objoff_34(a0)
                bcc.s   ArzRisingPillar_Return_Variant3
                move.w  #3,objoff_34(a0)
                subq.w  #4,y_pos(a0)
                addq.b  #4,y_radius(a0)
                addq.b  #1,mapping_frame(a0)
                cmpi.b  #6,mapping_frame(a0)
                bne.s   ArzRisingPillar_Return_Variant3
                move.b  #4,routine_secondary(a0)

ArzRisingPillar_Return_Variant3:
                rts
; ===========================================================================

loc_25B8E:

                tst.b   objoff_3F(a0)
                beq.s   loc_25B9A
                subq.b  #1,objoff_3F(a0)
                bra.s   loc_25BA4
; ===========================================================================

loc_25B9A:
                jsrto   JmpTo12_ObjectMove
                addi.w  #$18,y_vel(a0)

loc_25BA4:
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.w  JmpTo28_DeleteObject
                jmpto   JmpTo16_DisplaySprite

; ===========================================================================
byte_25BB0:
                dc.b    0
                dc.b    0                               ; 1
                dc.b    0                               ; 2
                dc.b    0                               ; 3
                dc.b    4                               ; 4
                dc.b    4                               ; 5
                dc.b    8                               ; 6
                dc.b    8                               ; 7
                dc.b    $C                              ; 8
                dc.b    $C                              ; 9
                dc.b    $10                             ; 10
                dc.b    $10                             ; 11
                dc.b    $14                             ; 12
                dc.b    $14                             ; 13
                even
word_25BBE:
                dc.w    -$200,-$200,$200,-$200          ; 0
                dc.w    -$1C0,-$1C0,$1C0,-$1C0          ; 4
                dc.w    -$180,-$180,$180,-$180          ; 8
                dc.w    -$140,-$140,$140,-$140          ; 12
                dc.w    -$100,-$100,$100,-$100          ; 16
                dc.w    -$C0, -$C0, $C0, -$C0           ; 20
                dc.w    -$80, -$80, $80, -$80           ; 24
; ===========================================================================

ArzRisingPillar_CreateSpriteFragments:
                moveq   #0,d0
                move.b  mapping_frame(a0),d0
                add.w   d0,d0
                movea.l mappings(a0),a3
                adda.w  (a3,d0.w),a3
                move.w  (a3)+,d1
                subq.w  #1,d1
                bset    #render_flags.static_mappings,render_flags(a0)
                _move.b id(a0),d4
                move.b  render_flags(a0),d5
                movea.l a0,a1
                bra.s   loc_25C24
; ===========================================================================

ArzRisingPillar_CountedLoopD1:
                jsrto   JmpTo10_AllocateObjectAfterCurrent
                bne.s   loc_25C64
                addq.w  #8,a3

loc_25C24:
                move.b  #4,routine(a1)
                _move.b d4,id(a1)                       ; load obj2B?
                move.l  a3,mappings(a1)
                move.b  d5,render_flags(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.w  art_tile(a0),art_tile(a1)
                move.b  priority(a0),priority(a1)
                move.b  width_pixels(a0),width_pixels(a1)
                move.w  (a4)+,x_vel(a1)
                move.w  (a4)+,y_vel(a1)
                move.b  (a2)+,objoff_3F(a1)
                dbf     d1,ArzRisingPillar_CountedLoopD1

loc_25C64:
                move.w  #SndID_SlowSmash,d0
                jmp     (PlaySound).l
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj2B_MapUnc_25C6E:
Map_obj2B:      mappingsTable
                mappingsTableEntry.w Map_obj2B_001C
                mappingsTableEntry.w Map_obj2B_004E
                mappingsTableEntry.w Map_obj2B_0088
                mappingsTableEntry.w Map_obj2B_00C2
                mappingsTableEntry.w Map_obj2B_0104
                mappingsTableEntry.w Map_obj2B_0146
                mappingsTableEntry.w Map_obj2B_0190
                mappingsTableEntry.w Map_obj2B_01DA
                mappingsTableEntry.w Map_obj2B_021C
                mappingsTableEntry.w Map_obj2B_026E
                mappingsTableEntry.w Map_obj2B_02C0
                mappingsTableEntry.w Map_obj2B_0322
                mappingsTableEntry.w Map_obj2B_0384
                mappingsTableEntry.w Map_obj2B_03F6

Map_obj2B_001C: spriteHeader
                spritePiece -$10, $10, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$18, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$18, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$18, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -8, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_001C_End

Map_obj2B_004E: spriteHeader
                spritePiece -$10, $14, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$1C, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$1C, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$1C, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$C, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, -4, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $C, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_004E_End

Map_obj2B_0088: spriteHeader
                spritePiece -$10, $18, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$20, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$20, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$20, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$10, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $10, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_0088_End

Map_obj2B_00C2: spriteHeader
                spritePiece -$10, $1C, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$24, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$24, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$24, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$14, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, -4, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 4, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $14, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_00C2_End

Map_obj2B_0104: spriteHeader
                spritePiece -$10, $20, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$28, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$28, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$28, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, -8, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $18, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_0104_End

Map_obj2B_0146: spriteHeader
                spritePiece -$10, $24, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$2C, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$2C, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$2C, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$1C, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, -$C, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 4, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $C, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $1C, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_0146_End

Map_obj2B_0190: spriteHeader
                spritePiece -$10, $28, 4, 2, $8B, 0, 0, 1, 0
                spritePiece -$20, -$30, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$30, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$30, 4, 2, $61, 0, 0, 0, 0
                spritePiece -$10, -$20, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, -$10, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $10, 4, 2, $69, 0, 0, 0, 0
                spritePiece -$10, $20, 4, 2, $83, 0, 0, 0, 0
Map_obj2B_0190_End

Map_obj2B_01DA: spriteHeader
                spritePiece -$20, -$18, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$18, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$18, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$18, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -8, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 8, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, 8, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_01DA_End

Map_obj2B_021C: spriteHeader
                spritePiece -$20, -$1C, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$1C, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$1C, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$1C, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$C, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$C, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $C, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $C, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_021C_End

Map_obj2B_026E: spriteHeader
                spritePiece -$20, -$20, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$20, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$20, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$20, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$10, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 0, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, 0, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $10, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $10, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_026E_End

Map_obj2B_02C0: spriteHeader
                spritePiece -$20, -$24, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$24, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$24, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$24, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$14, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$14, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 4, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, 4, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $14, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $14, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_02C0_End

Map_obj2B_0322: spriteHeader
                spritePiece -$20, -$28, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$28, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$28, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$28, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$18, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$18, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, -8, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 8, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, 8, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $18, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $18, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_0322_End

Map_obj2B_0384: spriteHeader
                spritePiece -$20, -$2C, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$2C, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$2C, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$2C, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$1C, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$1C, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, -$C, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$C, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 4, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, 4, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $C, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, $C, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $1C, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $1C, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_0384_End

Map_obj2B_03F6: spriteHeader
                spritePiece -$20, -$30, 2, 2, $5D, 0, 0, 0, 0
                spritePiece $10, -$30, 2, 2, $5D, 1, 0, 0, 0
                spritePiece -$10, -$30, 2, 2, $61, 0, 0, 0, 0
                spritePiece 0, -$30, 2, 2, $65, 0, 0, 0, 0
                spritePiece -$10, -$20, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$20, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, -$10, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, 0, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, 0, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $10, 2, 2, $69, 0, 0, 0, 0
                spritePiece 0, $10, 2, 2, $6D, 0, 0, 0, 0
                spritePiece -$10, $20, 2, 2, $83, 0, 0, 0, 0
                spritePiece 0, $20, 2, 2, $87, 0, 0, 0, 0
Map_obj2B_03F6_End

                even
; ===========================================================================

                jmpTos  JmpTo16_DisplaySprite,JmpTo28_DeleteObject,JmpTo16_MarkObjGone,JmpTo10_AllocateObjectAfterCurrent,JmpTo25_Adjust2PArtPointer,JmpTo8_SolidObject,JmpTo12_ObjectMove

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2C - Sprite that makes leaves fly off when you hit it from ARZ
; ---------------------------------------------------------------------------
; Sprite_26104:
