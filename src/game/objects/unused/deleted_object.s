ObjBB:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjBB_Index(pc,d0.w),d1
                jmp     ObjBB_Index(pc,d1.w)
; ===========================================================================
; off_3BB8A:
ObjBB_Index:    offsetTable
                offsetTableEntry.w ObjBB_Init           ; 0
                offsetTableEntry.w ObjBB_Main           ; 2
; ===========================================================================
; BranchTo8_LoadSubObject
ObjBB_Init:
                bra.w   LoadSubObject
; ===========================================================================
; BranchTo15_JmpTo39_MarkObjGone
ObjBB_Main:
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
; off_3BB96:
ObjBB_SubObjData:
                subObjData ObjBB_MapUnc_3BBA0,make_art_tile(ArtTile_ArtNem_Unknown,1,0),1<<render_flags.level_fg,4,$C,9
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBB_MapUnc_3BBA0:
Map_objBB:      mappingsTable
                mappingsTableEntry.w Map_objBB_0002

Map_objBB_0002: spriteHeader
                spritePiece -$C, -$40, 2, 2, 0, 0, 0, 0, 0
                spritePiece -4, -$30, 1, 4, 4, 0, 0, 0, 0
                spritePiece -$C, -$10, 3, 4, 8, 0, 0, 0, 0
Map_objBB_0002_End

                even
; ===========================================================================
; ----------------------------------------------------------------------------
; Object BC - Fire coming out of Robotnik's ship in WFZ
; ----------------------------------------------------------------------------
; Sprite_3BBBC:
