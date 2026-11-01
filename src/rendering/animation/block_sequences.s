LoadAnimatedBlocks:
                cmpi.b  #hill_top_zone,(Current_Zone).w
                bne.s   +
                bsr.w   PatchHTZTiles
                move.b  #-1,(Anim_Counters+1).w
                move.w  #-1,(TempArray_LayerDef+$20).w
+
                cmpi.b  #chemical_plant_zone,(Current_Zone).w
                bne.s   +
                move.b  #-1,(Anim_Counters+1).w
+
                moveq   #0,d0
                move.b  (Current_Zone).w,d0
                add.w   d0,d0
                move.w  AnimPatMaps(pc,d0.w),d0
                lea     AnimPatMaps(pc,d0.w),a0
                tst.w   (Two_player_mode).w
                beq.s   +
                cmpi.b  #casino_night_zone,(Current_Zone).w
                bne.s   +
                lea     (APM_CNZ2P).l,a0
+
                tst.w   (a0)
                beq.s   +                               ; rts
                lea     (Block_Table).w,a1
                adda.w  (a0)+,a1
                move.w  (a0)+,d1
                tst.w   (Two_player_mode).w
                bne.s   LoadLevelBlocks_2P

; loc_40330:
LoadLevelBlocks:
                move.w  (a0)+,(a1)+                     ; copy blocks to RAM
                dbf     d1,LoadLevelBlocks              ; loop using d1
+
                rts
; ===========================================================================
; loc_40338:
LoadLevelBlocks_2P:
                move.w  (a0)+,d0
; 'd1', the loop counter, is overwritten with VRAM data
                move.w  d0,d1
                andi.w  #nontile_mask,d0                ; d0 holds the preserved non-tile data
                andi.w  #tile_mask,d1                   ; d1 holds the tile index (overwrites loop counter!)
                lsr.w   #1,d1                           ; half tile index
                or.w    d1,d0                           ; put them back together
                move.w  d0,(a1)+
                dbf     d1,LoadLevelBlocks_2P           ; loop using d1, which we just overwrote
                rts
; ===========================================================================

; --------------------------------------------------------------------------------------
; Animated Pattern Mappings (16x16)
; --------------------------------------------------------------------------------------
; off_40350:
AnimPatMaps:    zoneOrderedOffsetTable 2,1
                zoneOffsetTableEntry.w APM_EHZ          ; EHZ
                zoneOffsetTableEntry.w APM_Null         ; Zone 1
                zoneOffsetTableEntry.w APM_Null         ; WZ
                zoneOffsetTableEntry.w APM_Null         ; Zone 3
                zoneOffsetTableEntry.w APM_MTZ          ; MTZ1,2
                zoneOffsetTableEntry.w APM_MTZ          ; MTZ3
                zoneOffsetTableEntry.w APM_Null         ; WFZ
                zoneOffsetTableEntry.w APM_EHZ          ; HTZ
                zoneOffsetTableEntry.w APM_HPZ          ; HPZ
                zoneOffsetTableEntry.w APM_Null         ; Zone 9
                zoneOffsetTableEntry.w APM_OOZ          ; OOZ
                zoneOffsetTableEntry.w APM_Null         ; MCZ
                zoneOffsetTableEntry.w APM_CNZ          ; CNZ
                zoneOffsetTableEntry.w APM_CPZ          ; CPZ
                zoneOffsetTableEntry.w APM_DEZ          ; DEZ
                zoneOffsetTableEntry.w APM_ARZ          ; ARZ
                zoneOffsetTableEntry.w APM_Null         ; SCZ
                zoneTableEnd

begin_animpat   macro   {INTLABEL}
__LABEL__       label   *
__LABEL___Len   :=      __LABEL___End - __LABEL___Blocks
                    dc.w    $1800 - __LABEL___Len
                    dc.w    bytesToWcnt(__LABEL___Len)
__LABEL___Blocks:
                endm

; byte_40372:
APM_EHZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$0 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$4 ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$1 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$5 ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$8 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$C ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$9 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$D ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$10,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$14,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$11,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$15,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$2 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$6 ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$3 ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$7 ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$A ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$E ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$B ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$F ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$12,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$16,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$13,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$17,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$18,0,0,3,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$1A,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$19,0,0,3,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$1B,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$1C,0,0,3,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$1E,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZMountains+$1D,0,0,3,0),make_block_tile(ArtTile_ArtUnc_EHZMountains+$1F,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$0,1,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$1,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$1,1,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtKos_Checkers+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$0,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtKos_Checkers+$1,0,0,2,0),make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$1,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$0,1,0,2,0),make_block_tile(ArtTile_ArtKos_Checkers+$0,1,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_EHZPulseBall+$1,1,0,2,0),make_block_tile(ArtTile_ArtKos_Checkers+$1,1,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers1+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_Flowers1+$0,1,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers1+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_Flowers1+$1,1,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers2+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_Flowers2+$0,1,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers2+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_Flowers2+$1,1,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers3+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_Flowers3+$0,1,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers3+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_Flowers3+$1,1,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers4+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_Flowers4+$0,1,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Flowers4+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_Flowers4+$1,1,0,3,1)
APM_EHZ_End:

; byte_403EE:
APM_MTZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$0,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$0,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$1,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$1,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$2,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$2,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$3,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$3,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$E,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$E,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$F,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$F,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$C,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$C,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$D,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$D,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$A,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$A,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$B,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$B,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$8,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$8,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$9,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$9,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$6,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$6,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$7,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$7,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$4,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$4,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$5,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$5,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$2,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$2,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$3,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$3,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$0,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$1,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$4,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$4,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$5,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_1+$5,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$0,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$0,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$1,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$1,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$2,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$2,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$3,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$3,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$4,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$4,1,0,1,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$5,0,0,1,0),make_block_tile(ArtTile_ArtUnc_MTZAnimBack_2+$5,1,0,1,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,2,1),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$0    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$1    ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,2,1),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$2    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$3    ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$4    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$5    ,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$8    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$9    ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$6    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$7    ,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Lava+$A    ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Lava+$B    ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$E,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$E,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$F,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$F,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$C,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$C,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$D,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$D,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$A,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$A,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$B,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$B,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$8,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$8,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$9,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$9,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$6,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$6,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$7,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$7,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$4,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$4,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$5,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$5,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$2,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$3,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$3,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$0,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_MTZCylinder+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_MTZCylinder+$1,0,0,3,1)
APM_MTZ_End:

; byte_404C2:
APM_HPZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$1,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$2,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$3,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$4,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$5,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$6,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$7,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$1,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$2,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$3,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$4,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$5,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$6,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$7,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$0,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$1,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$2,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$3,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$4,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$5,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$6,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$7,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$2,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$3,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$4,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$5,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$6,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$7,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$2,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$3,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$4,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$5,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$6,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$7,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$2,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$3,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$4,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$5,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$6,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$7,0,0,2,0)

; In REV02, for some reason these blank tiles' palette line was changed to lines 3 and 4
; This is consistent with MTZ's blank tiles
; Notably, the new palette lines' first entry always happens to match the current VDP background colour
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$0,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$2,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$4,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$3,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$6,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$5,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$7,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$0,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$2,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$4,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$3,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$6,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$5,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$7,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$0,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$2,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$1,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$4,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$3,0,0,3,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$6,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$5,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$7,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$0,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$2,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$1,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$4,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$3,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$6,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$5,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_1+$7,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$0,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$2,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$1,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$4,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$3,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$6,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$5,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_2+$7,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$0,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$2,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$1,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$4,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$3,0,0,2,0),make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$6,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$5,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_HPZPulseOrb_3+$7,0,0,2,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
APM_HPZ_End:

; byte_405B6:
APM_OOZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_OOZPulseBall+$0,0,0,0,1),make_block_tile(ArtTile_ArtUnc_OOZPulseBall+$2,0,0,0,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_OOZPulseBall+$1,0,0,0,1),make_block_tile(ArtTile_ArtUnc_OOZPulseBall+$3,0,0,0,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_OOZSquareBall1+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_OOZSquareBall1+$1,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_OOZSquareBall1+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_OOZSquareBall1+$3,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_OOZSquareBall2+$0,0,0,3,0)
                dc.w    make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_OOZSquareBall2+$2,0,0,3,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_OOZSquareBall2+$1,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_OOZSquareBall2+$3,0,0,3,0),make_block_tile(ArtTile_ArtKos_LevelArt+$0,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$0,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$1,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$8,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$9,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$2,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$3,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$A,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$B,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$4,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$5,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$C,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$D,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$6,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$7,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil1+$E,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil1+$F,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$0,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$1,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$8,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$9,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$2,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$3,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$A,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$B,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$4,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$5,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$C,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$D,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$6,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$7,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Oil2+$E,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Oil2+$F,0,0,2,1)
APM_OOZ_End:

; byte_4061A:
APM_CNZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$4,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$5,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$8,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$C,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$9,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$D,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$6,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$3,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$7,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$A,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$E,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$B,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2+$F,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$4,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$5,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$8,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$C,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$9,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$D,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$6,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$3,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$7,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$A,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$E,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$B,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1+$F,0,0,3,1)
APM_CNZ_End:

; byte_406BE:
APM_CNZ2P:      begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_1_2p+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_2_2p+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$0,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$4,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$1,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$5,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$8,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$C,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$9,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$D,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$2,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$6,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$3,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$7,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$A,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$E,0,0,0,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$B,0,0,0,0),make_block_tile(ArtTile_ArtUnc_CNZSlotPics_3_2p+$F,0,0,0,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$4,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$5,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$8,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$C,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$9,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$D,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$6,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$3,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$7,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$A,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$E,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$B,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_2_2p+$F,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$0,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$4,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$1,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$5,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$8,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$C,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$9,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$D,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$2,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$6,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$3,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$7,0,0,3,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$A,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$E,0,0,3,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$B,0,0,3,1),make_block_tile(ArtTile_ArtUnc_CNZFlipTiles_1_2p+$F,0,0,3,1)
APM_CNZ2P_End:

; byte_40762:
APM_CPZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_CPZAnimBack+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_CPZAnimBack+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_CPZAnimBack+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_CPZAnimBack+$1,0,0,2,0)
APM_CPZ_End:

; byte_4076E:
APM_DEZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_DEZAnimBack+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_DEZAnimBack+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_DEZAnimBack+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_DEZAnimBack+$1,0,0,2,0)
APM_DEZ_End:

; byte_4077A:
APM_ARZ:        begin_animpat
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall3+$0  ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall3+$1  ,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall3+$2  ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall3+$3  ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall2+$0  ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall2+$1  ,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall2+$2  ,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall2+$3  ,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$0,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$1,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$2,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$3,0,0,2,1)

; These are invalid animation entries for waterfalls:
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$C,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$D,0,0,2,1)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$E,0,0,2,1),make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$F,0,0,2,1)

                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall3+$0  ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall3+$1  ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall3+$2  ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall3+$3  ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall2+$0  ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall2+$1  ,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall2+$2  ,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall2+$3  ,0,0,2,0)

                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$0,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$1,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$2,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall1_1+$3,0,0,2,0)

; These are invalid animation entries for waterfalls:
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$C,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$D,0,0,2,0)
                dc.w    make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$E,0,0,2,0),make_block_tile(ArtTile_ArtUnc_Waterfall1_2+$F,0,0,2,0)
APM_ARZ_End:

; byte_407BE:
APM_Null:       dc.w    0
; ===========================================================================
; loc_407C0:
PatchHTZTiles:
; When decompressed, 'ArtNem_HTZCliffs' will be $1800 bytes large
                lea     (ArtNem_HTZCliffs).l,a0
                lea     (Dynamic_Object_RAM_End-$1800).w,a4
                jsrto   JmpTo2_NemDecToRAM
                lea     (Dynamic_Object_RAM_End-$1800).w,a1
                lea_    Dynamic_HTZ.offsets,a4
                moveq   #0,d2
                moveq   #8-1,d4

RenderingAnimationBlockSequences_CountedLoopD4:
                moveq   #6-1,d3

RenderingAnimationBlockSequences_CountedLoopD3:
                moveq   #-1,d0
                move.w  (a4)+,d0
                movea.l d0,a2
                moveq   #32-1,d1

RenderingAnimationBlockSequences_CountedLoopD1:
; Copy four pixels
                move.l  (a1),(a2)+
; Clear the bytes in 'Object_RAM'
                move.l  d2,(a1)+

                dbf     d1,RenderingAnimationBlockSequences_CountedLoopD1
                dbf     d3,RenderingAnimationBlockSequences_CountedLoopD3
                adda.w  #6*2,a4
                dbf     d4,RenderingAnimationBlockSequences_CountedLoopD4
                rts
; ===========================================================================

                jmpTos  JmpTo2_NemDecToRAM

; ---------------------------------------------------------------------------
; Subroutine to draw the HUD
; ---------------------------------------------------------------------------

hud_letter_num_tiles    =       2
hud_letter_vdp_delta    =       vdpCommDelta(tiles_to_bytes(hud_letter_num_tiles))

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_40804:
