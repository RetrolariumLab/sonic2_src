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
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence0           ; 0
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence1           ; 1
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence2           ; 2
                offsetTableEntry.w SharedStakeOrb_Animation_Sequence3           ; 3
SharedStakeOrb_Animation_Sequence0:     dc.b    8,  3,  3,  4,  5,  5,  4,$FF
SharedStakeOrb_Animation_Sequence1:     dc.b    5,  0,  0,  0,  1,  2,  3,  3,  2,  1,  2,  3,  3,  1,$FF
SharedStakeOrb_Animation_Sequence2:     dc.b    $B,  0,  1,  2,  3,  4,  5,$FD,  3
SharedStakeOrb_Animation_Sequence3:     dc.b    $7F,  6,$FD,  2
                even

; --------------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------------
Obj71_MapUnc_11396: include "src/game/objects/environment/common/stake_orb/data/mappings_a.s"
; ----------------------------------------------------------------------------------------
; Unknown sprite mappings
; ----------------------------------------------------------------------------------------
Obj1C_MapUnc_113D6: include "src/game/objects/environment/common/bridge_stake/data/mappings_a.s"
; --------------------------------------------------------------------------------
; Unknown sprite mappings
; --------------------------------------------------------------------------------
Obj1C_MapUnc_113EE: include "src/game/objects/environment/common/bridge_stake/data/mappings_b.s"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj1C_MapUnc_11406: include "src/game/objects/environment/common/bridge_stake/data/mappings_c.s"
; --------------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------------
Obj1C_MapUnc_114AE: include "src/game/objects/environment/common/bridge_stake/data/mappings_d.s"
; --------------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------------
Obj1C_MapUnc_11552: include "src/game/objects/environment/common/bridge_stake/data/mappings_shared.s"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj71_MapUnc_11576: include "src/game/objects/environment/common/stake_orb/data/mappings_b.s"
; ===========================================================================

                jmpTos                                  ; Empty

; ----------------------------------------------------------------------------
; Object 2A - Stomper from MCZ
; ----------------------------------------------------------------------------
; Sprite_115C4:
