Obj71:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj71_Index(pc,d0.w),d1
                jmp     Obj71_Index(pc,d1.w)
; ===========================================================================
; off_112FE:
Obj71_Index:    offsetTable
                offsetTableEntry.w Obj71_Init           ; 0
                offsetTableEntry.w Obj71_Main           ; 2
; ---------------------------------------------------------------------------
; dword_11302:
Obj71_InitData:
                objsubdecl 3, Obj11_MapUnc_FC28,  make_art_tile(ArtTile_ArtNem_HPZ_Bridge,3,0), 4, 1  ; Hidden Palace bridge
                objsubdecl 0, Obj71_MapUnc_11396, make_art_tile(ArtTile_ArtNem_HPZOrb,3,1), $10, 1  ; Hidden Palace pulsing orb
                objsubdecl 0, Obj71_MapUnc_11576, make_art_tile(ArtTile_ArtNem_MtzLavaBubble,2,0), $10, 1  ; MTZ lava bubble
; ===========================================================================
; loc_1131A:
Obj71_Init:
                addq.b  #2,routine(a0)
                move.b  subtype(a0),d0
                andi.w  #$F,d0
                lsl.w   #3,d0
                lea     Obj71_InitData(pc),a1
                lea     (a1,d0.w),a1
                move.b  (a1),mapping_frame(a0)
                move.l  (a1)+,mappings(a0)
                move.w  (a1)+,art_tile(a0)
                bsr.w   Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  (a1)+,width_pixels(a0)
                move.b  (a1)+,priority(a0)
                move.b  subtype(a0),d0
                andi.w  #$F0,d0
                lsr.b   #4,d0
                move.b  d0,anim(a0)
; loc_1135C:
Obj71_Main:
                lea     (Ani_obj71).l,a1
                bsr.w   AnimateSprite
                bra.w   MarkObjGone
; ===========================================================================
; off_1136A:
Ani_obj71:      offsetTable
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence0  ; 0
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence1  ; 1
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence2  ; 2
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence3  ; 3
SharedStakeOrb_Animation_Sequence0: dc.b    8,  3,  3,  4,  5,  5,  4,$FF
SharedStakeOrb_Animation_Sequence1: dc.b    5,  0,  0,  0,  1,  2,  3,  3,  2,  1,  2,  3,  3,  1,$FF
SharedStakeOrb_Animation_Sequence2: dc.b    $B,  0,  1,  2,  3,  4,  5,$FD,  3
SharedStakeOrb_Animation_Sequence3: dc.b    $7F,  6,$FD,  2
                even

; --------------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------------
Obj71_MapUnc_11396:
Map_obj71_a:    mappingsTable
                mappingsTableEntry.w Map_obj71_a_0008
                mappingsTableEntry.w Map_obj71_a_0012
                mappingsTableEntry.w Map_obj71_a_001C
                mappingsTableEntry.w Map_obj71_a_002E

Map_obj71_a_0008:   spriteHeader
                spritePiece -$C, -$C, 3, 3, 0, 0, 0, 0, 0
Map_obj71_a_0008_End

Map_obj71_a_0012:   spriteHeader
                spritePiece -$C, -$C, 3, 3, 9, 0, 0, 0, 0
Map_obj71_a_0012_End

Map_obj71_a_001C:   spriteHeader
                spritePiece -$10, -$10, 4, 2, $12, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 2, $12, 1, 1, 0, 0
Map_obj71_a_001C_End

Map_obj71_a_002E:   spriteHeader
                spritePiece -$10, -$10, 4, 2, $1A, 0, 0, 0, 0
                spritePiece -$10, 0, 4, 2, $1A, 1, 1, 0, 0
Map_obj71_a_002E_End

                even
; ----------------------------------------------------------------------------------------
; Unknown sprite mappings
; ----------------------------------------------------------------------------------------
Obj1C_MapUnc_113D6: include "src/game/objects/environment/common/bridge_stake/mappings.s"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj71_MapUnc_11576:
Map_obj71_b:    mappingsTable
                mappingsTableEntry.w Map_obj71_b_000E
                mappingsTableEntry.w Map_obj71_b_0018
                mappingsTableEntry.w Map_obj71_b_0022
                mappingsTableEntry.w Map_obj71_b_002C
                mappingsTableEntry.w Map_obj71_b_0036
                mappingsTableEntry.w Map_obj71_b_0040
                mappingsTableEntry.w Map_obj71_b_004A

Map_obj71_b_000E:   spriteHeader
                spritePiece -8, 2, 2, 1, 0, 0, 0, 0, 0
Map_obj71_b_000E_End

Map_obj71_b_0018:   spriteHeader
                spritePiece -8, 0, 2, 1, 0, 0, 0, 0, 0
Map_obj71_b_0018_End

Map_obj71_b_0022:   spriteHeader
                spritePiece -8, -2, 2, 1, 0, 0, 0, 0, 0
Map_obj71_b_0022_End

Map_obj71_b_002C:   spriteHeader
                spritePiece -8, -4, 2, 1, 0, 0, 0, 0, 0
Map_obj71_b_002C_End

Map_obj71_b_0036:   spriteHeader
                spritePiece -$C, -4, 3, 1, 2, 0, 0, 0, 0
Map_obj71_b_0036_End

Map_obj71_b_0040:   spriteHeader
                spritePiece -$10, -4, 4, 1, 5, 0, 0, 0, 0
Map_obj71_b_0040_End

Map_obj71_b_004A:   spriteHeader
Map_obj71_b_004A_End

                even
; ===========================================================================

                jmpTos                                  ; Empty

; ----------------------------------------------------------------------------
; Object 2A - Stomper from MCZ
; ----------------------------------------------------------------------------
; Sprite_115C4:
