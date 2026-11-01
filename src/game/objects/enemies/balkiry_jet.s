Obj9C:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj9C_Index(pc,d0.w),d1
                jmp     Obj9C_Index(pc,d1.w)
; ===========================================================================
; off_37A90:
Obj9C_Index:    offsetTable
                offsetTableEntry.w Obj9C_Init
                offsetTableEntry.w Obj9C_Main
; ===========================================================================
; BranchTo2_LoadSubObject
Obj9C_Init:
                bra.w   LoadSubObject
; ===========================================================================
; loc_37A98:
Obj9C_Main:
                movea.w objoff_2C(a0),a1                ; a1=object
                move.b  objoff_32(a0),d0
                cmp.b   id(a1),d0
                bne.w   JmpTo65_DeleteObject
                move.l  x_pos(a1),x_pos(a0)
                move.l  y_pos(a1),y_pos(a0)
                movea.l objoff_2E(a0),a1
                jsrto   JmpTo25_AnimateSprite
                bra.w   Obj_DeleteBehindScreen
; ===========================================================================

loc_37ABE:
                jsrto   JmpTo25_AllocateObjectAfterCurrent
                bne.s   +                               ; rts
                _move.b #ObjID_BalkiryJet,id(a1)        ; load obj9C
                move.b  #6,mapping_frame(a1)
                move.b  #$1A,subtype(a1)                ; <== Obj9C_SubObjData
                move.w  a0,objoff_2C(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.l  objoff_2E(a0),objoff_2E(a1)
                move.b  id(a0),objoff_32(a1)
+
                rts

; ===========================================================================
; this code is for Obj9A

loc_37AF2:
                jsrto   JmpTo19_AllocateObject
                bne.s   +                               ; rts
                _move.b #ObjID_Projectile,id(a1)        ; load obj98
                move.b  #6,mapping_frame(a1)
                move.b  #$1C,subtype(a1)                ; <== Obj9A_SubObjData2
                move.w  x_pos(a0),x_pos(a1)
                subi.w  #$14,x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                addi.w  #$A,y_pos(a1)
                move.w  #-$100,x_vel(a1)
                lea_    Obj98_TurtloidShotMove,a2
                move.l  a2,objoff_2A(a1)
+
                rts
; ===========================================================================
; off_37B32:
Obj9A_SubObjData:
                subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),1<<render_flags.level_fg,5,$18,0
; off_37B3C:
Obj9B_SubObjData:
                subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),1<<render_flags.level_fg,4,$C,$1A
; off_37B46:
Obj9C_SubObjData:
                subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),1<<render_flags.level_fg,5,8,0

; animation script
; off_37B50: TurtloidShotAniData:
Ani_TurtloidShot:   offsetTable
                offsetTableEntry.w +
+               dc.b    1,  4,  5,$FF
                even

; animation script
; off_37B56:
Ani_obj9A:      offsetTable
                offsetTableEntry.w +
+               dc.b    1,  6,  7,$FF
                even

; animation script
; off_37B5C:
Ani_obj9C:      offsetTable
                offsetTableEntry.w +
+               dc.b    1,  8,  9,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj9A_Obj98_MapUnc_37B62:
Map_obj9C:      mappingsTable
                mappingsTableEntry.w Map_obj9C_0014
                mappingsTableEntry.w Map_obj9C_002E
                mappingsTableEntry.w Map_obj9C_0048
                mappingsTableEntry.w Map_obj9C_0052
                mappingsTableEntry.w Map_obj9C_005C
                mappingsTableEntry.w Map_obj9C_0066
                mappingsTableEntry.w Map_obj9C_0070
                mappingsTableEntry.w Map_obj9C_007A
                mappingsTableEntry.w Map_obj9C_0084
                mappingsTableEntry.w Map_obj9C_008E

Map_obj9C_0014: spriteHeader
                spritePiece -$1C, -$10, 3, 2, 0, 0, 0, 1, 1
                spritePiece -4, -$10, 4, 4, 6, 0, 0, 1, 1
                spritePiece -$1C, 0, 3, 2, $16, 0, 0, 1, 1
Map_obj9C_0014_End

Map_obj9C_002E: spriteHeader
                spritePiece -$1C, -$10, 3, 2, 0, 0, 0, 1, 1
                spritePiece -$1C, 0, 3, 2, $1C, 0, 0, 1, 1
                spritePiece -4, -$10, 4, 4, 6, 0, 0, 1, 1
Map_obj9C_002E_End

Map_obj9C_0048: spriteHeader
                spritePiece -$C, -$C, 3, 3, $22, 0, 0, 1, 1
Map_obj9C_0048_End

Map_obj9C_0052: spriteHeader
                spritePiece -$C, -$C, 3, 3, $2B, 0, 0, 1, 1
Map_obj9C_0052_End

Map_obj9C_005C: spriteHeader
                spritePiece -4, -4, 1, 1, $34, 0, 0, 0, 1
Map_obj9C_005C_End

Map_obj9C_0066: spriteHeader
                spritePiece -4, -4, 1, 1, $35, 0, 0, 0, 1
Map_obj9C_0066_End

Map_obj9C_0070: spriteHeader
                spritePiece $1C, 6, 2, 1, $36, 0, 0, 0, 1
Map_obj9C_0070_End

Map_obj9C_007A: spriteHeader
                spritePiece $1C, 6, 1, 1, $38, 0, 0, 0, 1
Map_obj9C_007A_End

Map_obj9C_0084: spriteHeader
                spritePiece $1B, -5, 2, 1, $36, 0, 0, 0, 1
Map_obj9C_0084_End

Map_obj9C_008E: spriteHeader
                spritePiece $1B, -5, 1, 1, $38, 0, 0, 0, 1
Map_obj9C_008E_End

                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 9D - Coconuts (monkey badnik) from EHZ
; ----------------------------------------------------------------------------
; OST Variables:
Obj9D_timer                 =       objoff_2A           ; byte
Obj9D_climb_table_index     =       objoff_2C           ; word
Obj9D_attack_timer          =       objoff_2E           ; byte ; time player needs to spend close to object before it attacks
; Sprite_37BFA:
