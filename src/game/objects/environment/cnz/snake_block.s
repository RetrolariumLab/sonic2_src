ObjD2:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjD2_Index(pc,d0.w),d1
                jmp     ObjD2_Index(pc,d1.w)
; ===========================================================================
; off_2B536:
ObjD2_Index:    offsetTable
                offsetTableEntry.w ObjD2_Init           ; 0
                offsetTableEntry.w ObjD2_Main           ; 2
; ===========================================================================
; loc_2B53A:
ObjD2_Init:
                addq.b  #2,routine(a0)
                move.l  #ObjD2_MapUnc_2B694,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_CNZSnake,2,0),art_tile(a0)
                jsrto   JmpTo51_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #8,width_pixels(a0)
                move.b  #4,priority(a0)
                move.w  x_pos(a0),objoff_30(a0)
                move.w  y_pos(a0),objoff_32(a0)
                moveq   #0,d0
                move.b  subtype(a0),d0
                lsl.w   #4,d0
                move.w  d0,objoff_38(a0)
                bsr.w   CnzSnakeBlock_ApplyFrameGeometry
; loc_2B57E:
ObjD2_Main:
                tst.w   objoff_38(a0)
                beq.s   +
                subq.w  #1,objoff_38(a0)
                jmpto   JmpTo6_MarkObjGone3
; ===========================================================================
+
                subq.w  #1,objoff_3A(a0)
                bpl.s   loc_2B5EC
                move.w  #$F,objoff_3A(a0)
                addq.b  #1,mapping_frame(a0)
                andi.b  #$F,mapping_frame(a0)
                bne.s   loc_2B5EA
                moveq   #0,d0
                move.b  subtype(a0),d0
                lsl.w   #4,d0
                move.w  d0,objoff_38(a0)
                move.b  status(a0),d0
                andi.b  #standing_mask,d0
                beq.s   loc_2B5E2
                bclr    #p1_standing_bit,status(a0)
                beq.s   +
                bclr    #status.player.on_object,(MainCharacter+status).w
                bset    #status.player.in_air,(MainCharacter+status).w
+
                bclr    #p2_standing_bit,status(a0)
                beq.s   loc_2B5E2
                bclr    #status.player.on_object,(Sidekick+status).w
                bset    #status.player.in_air,(Sidekick+status).w

loc_2B5E2:
                move.w  objoff_30(a0),x_pos(a0)
                bra.s   CnzSnakeBlock_ApplyFrameGeometry
; ===========================================================================

loc_2B5EA:
                bsr.s   CnzSnakeBlock_ApplyFrameGeometry

loc_2B5EC:
                move.w  objoff_34(a0),d1
                addi.w  #$B,d1
                move.w  objoff_36(a0),d2
                move.w  d2,d3
                addq.w  #1,d3
                move.w  x_pos(a0),d4
                jsrto   JmpTo24_SolidObject
                move.w  objoff_30(a0),d0
                jmpto   JmpTo9_MarkObjGone2
; ===========================================================================

CnzSnakeBlock_ApplyFrameGeometry:
                moveq   #0,d0
                move.b  mapping_frame(a0),d0
                add.w   d0,d0
                add.w   d0,d0
                lea     byte_2B654(pc,d0.w),a1
                move.b  (a1)+,d0
                ext.w   d0
                btst    #status.npc.x_flip,status(a0)
                beq.s   +
                neg.w   d0
+
                add.w   objoff_30(a0),d0
                move.w  d0,x_pos(a0)
                move.b  (a1)+,d0
                ext.w   d0
                add.w   objoff_32(a0),d0
                move.w  d0,y_pos(a0)
                moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d3
                move.b  (a1)+,d1
                move.b  (a1)+,d2
                move.w  d1,objoff_34(a0)
                move.b  d1,width_pixels(a0)
                move.w  d2,objoff_36(a0)
                rts
; ===========================================================================
byte_2B654:
                dc.b    -$28, $18,   8,   8             ; $00
                dc.b    -$28, $10,   8 ,$10             ; $01
                dc.b    -$28,   8,   8, $18             ; $02
                dc.b    -$28,   0,   8, $20             ; $03
                dc.b    -$20,   0, $10, $20             ; $04
                dc.b    -$18,-$08, $18, $18             ; $05
                dc.b    -$10,-$10, $20, $10             ; $06
                dc.b    -$08,-$18, $28,   8             ; $07
                dc.b    8,-$18, $28,   8                ; $08
                dc.b    $10,-$10, $20, $10              ; $09
                dc.b    $18,-$08, $18, $18              ; $0A
                dc.b    $20,   0, $10, $20              ; $0B
                dc.b    $28,   0,   8, $20              ; $0C
                dc.b    $28,   8,   8, $18              ; $0D
                dc.b    $28, $10,   8, $10              ; $0E
                dc.b    $28, $18,   8,   8              ; $0F
                even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
ObjD2_MapUnc_2B694:
Map_objD2:      mappingsTable
                mappingsTableEntry.w Map_objD2_0020
                mappingsTableEntry.w Map_objD2_002A
                mappingsTableEntry.w Map_objD2_003C
                mappingsTableEntry.w Map_objD2_0056
                mappingsTableEntry.w Map_objD2_0078
                mappingsTableEntry.w Map_objD2_00A2
                mappingsTableEntry.w Map_objD2_00CC
                mappingsTableEntry.w Map_objD2_00F6
                mappingsTableEntry.w Map_objD2_00F6
                mappingsTableEntry.w Map_objD2_0120
                mappingsTableEntry.w Map_objD2_014A
                mappingsTableEntry.w Map_objD2_0174
                mappingsTableEntry.w Map_objD2_0056
                mappingsTableEntry.w Map_objD2_003C
                mappingsTableEntry.w Map_objD2_002A
                mappingsTableEntry.w Map_objD2_0020

Map_objD2_0020: spriteHeader
                spritePiece -8, -8, 2, 2, 0, 0, 0, 0, 0
Map_objD2_0020_End

Map_objD2_002A: spriteHeader
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
Map_objD2_002A_End

Map_objD2_003C: spriteHeader
                spritePiece -8, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 8, 2, 2, 0, 0, 0, 0, 0
Map_objD2_003C_End

Map_objD2_0056: spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, $10, 2, 2, 0, 0, 0, 0, 0
Map_objD2_0056_End

Map_objD2_0078: spriteHeader
                spritePiece 0, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, $10, 2, 2, 0, 0, 0, 0, 0
Map_objD2_0078_End

Map_objD2_00A2: spriteHeader
                spritePiece 8, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 8, 2, 2, 0, 0, 0, 0, 0
Map_objD2_00A2_End

Map_objD2_00CC: spriteHeader
                spritePiece $10, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, 0, 2, 2, 0, 0, 0, 0, 0
Map_objD2_00CC_End

Map_objD2_00F6: spriteHeader
                spritePiece $18, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 8, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$28, -8, 2, 2, 0, 0, 0, 0, 0
Map_objD2_00F6_End

Map_objD2_0120: spriteHeader
                spritePiece $10, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece $10, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, -$10, 2, 2, 0, 0, 0, 0, 0
Map_objD2_0120_End

Map_objD2_014A: spriteHeader
                spritePiece 8, 8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 8, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 8, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, -$18, 2, 2, 0, 0, 0, 0, 0
Map_objD2_014A_End

Map_objD2_0174: spriteHeader
                spritePiece 0, $10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -$20, 2, 2, 0, 0, 0, 0, 0
Map_objD2_0174_End

                even
; ===========================================================================

                jmpTos  JmpTo6_MarkObjGone3,JmpTo51_Adjust2PArtPointer,JmpTo24_SolidObject,JmpTo9_MarkObjGone2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object D3 - Bomb prize from CNZ
; ---------------------------------------------------------------------------
; Note: see object DC (ring prize) for SST entries (casino_prize_*)

; Sprite_2B84C:
