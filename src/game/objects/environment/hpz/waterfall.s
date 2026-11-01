Obj13:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj13_Index(pc,d0.w),d1
                jmp     Obj13_Index(pc,d1.w)
; ===========================================================================
; off_203BA
Obj13_Index:    offsetTable
                offsetTableEntry.w Obj13_Init           ; 0
                offsetTableEntry.w Obj13_Main           ; 2
                offsetTableEntry.w Obj13_ChkDel         ; 4
; ===========================================================================
; loc_203C0:
Obj13_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj13_MapUnc_20528,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_HPZ_Waterfall,3,1),art_tile(a0)
                jsrto   JmpTo11_Adjust2PArtPointer
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #1,priority(a0)
                move.b  #$12,mapping_frame(a0)
                bsr.s   Obj13_LoadSubObject
                move.b  #$A0,y_radius(a1)
                bset    #render_flags.explicit_height,render_flags(a1)
                move.l  a1,objoff_38(a0)
                move.w  y_pos(a0),objoff_34(a0)
                move.w  y_pos(a0),objoff_36(a0)
                cmpi.b  #$10,subtype(a0)
                blo.s   loc_2046C
                bsr.s   Obj13_LoadSubObject
                move.l  a1,objoff_3C(a0)
                move.w  y_pos(a0),y_pos(a1)
                addi.w  #$98,y_pos(a1)
                bra.s   loc_2046C
; ===========================================================================
; loc_20428:
Obj13_LoadSubObject:
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   +                               ; rts
                _move.b #ObjID_HPZWaterfall,id(a1)      ; load obj13
                addq.b  #4,routine(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.l  #Obj13_MapUnc_20528,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_HPZ_Waterfall,3,1),art_tile(a1)
                jsrto   JmpTo2_Adjust2PArtPointer2
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$10,width_pixels(a1)
                move.b  #1,priority(a1)
+               rts
; ===========================================================================

loc_2046C:
                moveq   #0,d1
                move.b  subtype(a0),d1
                move.w  objoff_34(a0),d0
                subi.w  #$78,d0
                lsl.w   #4,d1
                add.w   d1,d0
                move.w  d0,y_pos(a0)
                move.w  d0,objoff_34(a0)
; loc_20486:
Obj13_Main:
                movea.l objoff_38(a0),a1                ; a1=object
                move.b  #$12,mapping_frame(a0)
                move.w  objoff_34(a0),d0
                move.w  (Water_Level_1).w,d1
                cmp.w   d0,d1
                bhs.s   +
                move.w  d1,d0
+
                move.w  d0,y_pos(a0)
                sub.w   objoff_36(a0),d0
                addi.w  #$80,d0
                bmi.s   loc_204F0
                lsr.w   #4,d0
                move.w  d0,d1
                cmpi.w  #$F,d0
                blo.s   +
                moveq   #$F,d0
+
                move.b  d0,mapping_frame(a1)
                cmpi.b  #$10,subtype(a0)
                blo.s   loc_204D8
                movea.l objoff_3C(a0),a1                ; a1=object
                subi.w  #$F,d1
                bcc.s   +
                moveq   #0,d1
+
                addi.w  #$13,d1
                move.b  d1,mapping_frame(a1)

loc_204D8:
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   JmpTo17_DeleteObject
                jmpto   JmpTo9_DisplaySprite
; ===========================================================================

loc_204F0:
                moveq   #$13,d0
                move.b  d0,mapping_frame(a0)
                move.b  d0,mapping_frame(a1)
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   JmpTo17_DeleteObject
                rts

; ===========================================================================
; loc_20510:
Obj13_ChkDel:
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   JmpTo17_DeleteObject
                jmpto   JmpTo9_DisplaySprite
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings (unused)
; -------------------------------------------------------------------------------
Obj13_MapUnc_20528:
Map_obj13:      mappingsTable
                mappingsTableEntry.w Map_obj13_003A
                mappingsTableEntry.w Map_obj13_0044
                mappingsTableEntry.w Map_obj13_0056
                mappingsTableEntry.w Map_obj13_0068
                mappingsTableEntry.w Map_obj13_0082
                mappingsTableEntry.w Map_obj13_009C
                mappingsTableEntry.w Map_obj13_00BE
                mappingsTableEntry.w Map_obj13_00E0
                mappingsTableEntry.w Map_obj13_010A
                mappingsTableEntry.w Map_obj13_0134
                mappingsTableEntry.w Map_obj13_0166
                mappingsTableEntry.w Map_obj13_0198
                mappingsTableEntry.w Map_obj13_01D2
                mappingsTableEntry.w Map_obj13_020C
                mappingsTableEntry.w Map_obj13_024E
                mappingsTableEntry.w Map_obj13_0290
                mappingsTableEntry.w Map_obj13_02DA
                mappingsTableEntry.w Map_obj13_02DA
                mappingsTableEntry.w Map_obj13_02DA
                mappingsTableEntry.w Map_obj13_0038
                mappingsTableEntry.w Map_obj13_02EC
                mappingsTableEntry.w Map_obj13_02F6
                mappingsTableEntry.w Map_obj13_0300
                mappingsTableEntry.w Map_obj13_0312
                mappingsTableEntry.w Map_obj13_0324
                mappingsTableEntry.w Map_obj13_033E
                mappingsTableEntry.w Map_obj13_0358
                mappingsTableEntry.w Map_obj13_037A

Map_obj13_0038: spriteHeader
Map_obj13_0038_End

Map_obj13_003A: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
Map_obj13_003A_End

Map_obj13_0044: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0044_End

Map_obj13_0056: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
Map_obj13_0056_End

Map_obj13_0068: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0068_End

Map_obj13_0082: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
Map_obj13_0082_End

Map_obj13_009C: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_009C_End

Map_obj13_00BE: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
Map_obj13_00BE_End

Map_obj13_00E0: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_00E0_End

Map_obj13_010A: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
Map_obj13_010A_End

Map_obj13_0134: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0134_End

Map_obj13_0166: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
Map_obj13_0166_End

Map_obj13_0198: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $28, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0198_End

Map_obj13_01D2: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $28, 4, 4, 0, 0, 0, 0, 0
Map_obj13_01D2_End

Map_obj13_020C: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $28, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $48, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_020C_End

Map_obj13_024E: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $28, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $48, 4, 4, 0, 0, 0, 0, 0
Map_obj13_024E_End

Map_obj13_0290: spriteHeader
                spritePiece -$10, -$80, 4, 1, $10, 0, 0, 0, 0
                spritePiece -$10, -$78, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$58, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$38, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, -$18, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 8, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $28, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $48, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $68, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0290_End

Map_obj13_02DA: spriteHeader
                spritePiece -$18, -$10, 3, 3, $18, 0, 0, 0, 0
                spritePiece 0, -$10, 3, 3, $18, 1, 0, 0, 0
Map_obj13_02DA_End

Map_obj13_02EC: spriteHeader
                spritePiece -$10, -$20, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_02EC_End

Map_obj13_02F6: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
Map_obj13_02F6_End

Map_obj13_0300: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0300_End

Map_obj13_0312: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 4, 0, 0, 0, 0, 0
Map_obj13_0312_End

Map_obj13_0324: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $20, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0324_End

Map_obj13_033E: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $20, 4, 4, 0, 0, 0, 0, 0
Map_obj13_033E_End

Map_obj13_0358: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $40, 4, 2, $2D, 0, 0, 0, 0
Map_obj13_0358_End

Map_obj13_037A: spriteHeader
                spritePiece -$10, -$20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $20, 4, 4, 0, 0, 0, 0, 0
                spritePiece -$10, $40, 4, 4, 0, 0, 0, 0, 0
Map_obj13_037A_End

                even
; ===========================================================================

                jmpTos  JmpTo9_DisplaySprite,JmpTo17_DeleteObject,JmpTo2_Adjust2PArtPointer2,JmpTo11_Adjust2PArtPointer

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 04 - Surface of the water - water surface
; ----------------------------------------------------------------------------
