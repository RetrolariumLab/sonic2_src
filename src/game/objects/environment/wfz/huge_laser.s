ObjB7:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjB7_Index(pc,d0.w),d1
                jmp     ObjB7_Index(pc,d1.w)
; ===========================================================================
; off_3B8B4:
ObjB7_Index:    offsetTable
                offsetTableEntry.w ObjB7_Init           ; 0
                offsetTableEntry.w ObjB7_Main           ; 2
; ===========================================================================
; loc_3B8B8:
ObjB7_Init:
                bsr.w   LoadSubObject
                move.b  #$20,objoff_2A(a0)
                rts
; ===========================================================================
; loc_3B8C4:
ObjB7_Main:
                subq.b  #1,objoff_2A(a0)
                beq.w   JmpTo65_DeleteObject
                bchg    #0,objoff_2B(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
; off_3B8DA:
ObjB7_SubObjData:
                subObjData ObjB7_MapUnc_3B8E4,make_art_tile(ArtTile_ArtNem_WfzVrtclLazer,2,1),1<<render_flags.level_fg,4,$18,$A9
ObjB7_MapUnc_3B8E4:
Map_objB7:      mappingsTable
                mappingsTableEntry.w Map_objB7_0002

Map_objB7_0002: spriteHeader
                spritePiece -$18, -$70, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, -$70, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, -$50, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, -$50, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, -$30, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, -$30, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, -$10, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, -$10, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, $10, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, $10, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, $30, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, $30, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, $50, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, $50, 3, 4, 0, 1, 0, 0, 0
                spritePiece -$18, $70, 3, 4, 0, 0, 0, 0, 0
                spritePiece 0, $70, 3, 4, 0, 1, 0, 0, 0
Map_objB7_0002_End

                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object B8 - Wall turret from WFZ
; ----------------------------------------------------------------------------
; Sprite_3B968:
