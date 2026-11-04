GetAddressOfBlockInChunk:
                movem.l d4-d5,-(sp)
                move.w  d4,d3                           ; d3 = camera Y pos + offset
                add.w   d3,d3
                andi.w  #$F00,d3                        ; limit to units of $100 ($100 = size of a row of FG and BG 128x128s in level layout table)
                lsr.w   #3,d5                           ; divide by 8
                move.w  d5,d0
                lsr.w   #4,d0                           ; divide by 16 (overall division of 128)
                andi.w  #$7F,d0
                add.w   d3,d0                           ; get offset of current 128x128 in the level layout table
                moveq   #-1,d3
                clr.w   d3                              ; d3 = $FFFF0000
                move.b  (a4,d0.w),d3                    ; get tile ID of the current 128x128 tile
                lsl.w   #7,d3                           ; multiply by 128, the size in bytes of a 128x128 in RAM
                andi.w  #$70,d4                         ; round down to nearest 16-pixel boundary
                andi.w  #$E,d5                          ; force this to be a multiple of 16
                add.w   d4,d3                           ; add vertical offset of current 16x16
                add.w   d5,d3                           ; add horizontal offset of current 16x16
                movea.l d3,a0                           ; store address, in the metablock table, of the current 16x16
                movem.l (sp)+,d4-d5
                rts
; End of function GetAddressOfBlockInChunk

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E0D4: ProcessAndWriteBlock:
ProcessAndWriteBlock_Horizontal:
; Compared to 'ProcessAndWriteBlock_Vertical', this caches the bottom
; two tiles far later writing. This avoids the need to constantly
; alternate VRAM destinations
                btst    #3,(a0)                         ; is this 16x16 to be Y-flipped?
                bne.s   .flipY                          ; if it is, branch
                btst    #2,(a0)                         ; is this 16x16 to be X-flipped?
                bne.s   .flipX                          ; if it is, branch
                move.l  (a1)+,(a6)                      ; write top two 8x8s to VRAM
                move.l  (a1)+,(a2)+                     ; store bottom two 8x8s for later writing
                rts
; ===========================================================================
; ProcessAndWriteBlock_FlipX:
.flipX:
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3         ; toggle X-flip flag of the 8x8s
                swap    d3                              ; swap the position of the 8x8s
                move.l  d3,(a6)                         ; write top two 8x8s to VRAM
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3
                swap    d3
                move.l  d3,(a2)+                        ; store bottom two 8x8s for later writing
                rts
; ===========================================================================
; ProcessAndWriteBlock_FlipY:
.flipY:
                btst    #2,(a0)                         ; is this 16x16 to be X-flipped as well?
                bne.s   .flipXY                         ; if it is, branch
                move.l  (a1)+,d0
                move.l  (a1)+,d3
                eori.l  #(flip_y<<16)|flip_y,d3         ; toggle Y-flip flag of the 8x8s
                move.l  d3,(a6)                         ; write bottom two 8x8s to VRAM
                eori.l  #(flip_y<<16)|flip_y,d0
                move.l  d0,(a2)+                        ; store top two 8x8s for later writing
                rts
; ===========================================================================
; ProcessAndWriteBlock_FlipXY:
.flipXY:
                move.l  (a1)+,d0
                move.l  (a1)+,d3
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d3  ; toggle X and Y-flip flags of the 8x8s
                swap    d3
                move.l  d3,(a6)                         ; write bottom two 8x8s to VRAM
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d0
                swap    d0
                move.l  d0,(a2)+                        ; store top two 8x8s for later writing
                rts
; End of function ProcessAndWriteBlock_Horizontal

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E136: ProcessAndWriteBlock_2P:
WriteInterlacedBlock_Horizontal:
; In two player mode, the VDP's Interlace Mode 2 is enabled, making
; tiles twice as tall (16x8 instead of 8x8). Because of this, blocks
; are now composed of only two tiles, arranged side by side
                btst    #3,(a0)
                bne.s   .flipY
                btst    #2,(a0)
                bne.s   .flipX
                move.l  (a1)+,(a6)
                rts
; ===========================================================================
; loc_E146:
.flipX:
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3
                swap    d3
                move.l  d3,(a6)
                rts
; ===========================================================================
; loc_E154:
.flipY:
                btst    #2,(a0)
                bne.s   .flipXY
                move.l  (a1)+,d3
                eori.l  #(flip_y<<16)|flip_y,d3
                move.l  d3,(a6)
                rts
; ===========================================================================
; loc_E166:
.flipXY:
                move.l  (a1)+,d3
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d3
                swap    d3
                move.l  d3,(a6)
                rts
; End of function WriteInterlacedBlock_Horizontal

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E174: ProcessAndWriteBlock2:
ProcessAndWriteBlock_Vertical:
                or.w    d2,d0
                swap    d0                              ; make VRAM write command
                btst    #3,(a0)                         ; is the 16x16 to be Y-flipped?
                bne.s   .flipY                          ; if it is, branch
                btst    #2,(a0)                         ; is the 16x16 to be X-flipped?
                bne.s   .flipX                          ; if it is, branch
                move.l  d0,(a5)                         ; write to this VRAM address
                move.l  (a1)+,(a6)                      ; write top two 8x8s
                add.l   d7,d0                           ; move onto next line
                move.l  d0,(a5)
                move.l  (a1)+,(a6)                      ; write bottom two 8x8s
                rts
; ===========================================================================
; ProcessAndWriteBlock2_FlipX:
.flipX:
                move.l  d0,(a5)
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3         ; toggle X-flip flag of the 8x8s
                swap    d3                              ; swap the position of the 8x8s
                move.l  d3,(a6)                         ; write top two 8x8s
                add.l   d7,d0                           ; move onto next line
                move.l  d0,(a5)
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3
                swap    d3
                move.l  d3,(a6)                         ; write bottom two 8x8s
                rts
; ===========================================================================
; ProcessAndWriteBlock2_FlipY:
.flipY:
                btst    #2,(a0)                         ; is the 16x16 to be X-flipped as well?
                bne.s   .flipXY                         ; if it is, branch
                move.l  d5,-(sp)
                move.l  d0,(a5)
                move.l  (a1)+,d5
                move.l  (a1)+,d3
                eori.l  #(flip_y<<16)|flip_y,d3         ; toggle Y-flip flag of 8x8s
                move.l  d3,(a6)                         ; write bottom two 8x8s
                add.l   d7,d0                           ; move onto next line
                move.l  d0,(a5)
                eori.l  #(flip_y<<16)|flip_y,d5
                move.l  d5,(a6)                         ; write top two 8x8s
                move.l  (sp)+,d5
                rts
; ===========================================================================
; ProcessAndWriteBlock2_FlipXY:
.flipXY:
                move.l  d5,-(sp)
                move.l  d0,(a5)
                move.l  (a1)+,d5
                move.l  (a1)+,d3
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d3  ; toggle X and Y-flip flags of 8x8s
                swap    d3                              ; swap the position of the 8x8s
                move.l  d3,(a6)                         ; write bottom two 8x8s
                add.l   d7,d0
                move.l  d0,(a5)
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d5
                swap    d5
                move.l  d5,(a6)                         ; write top two 8x8s
                move.l  (sp)+,d5
                rts
; End of function ProcessAndWriteBlock_Vertical

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E1FA: ProcessAndWriteBlock2_2P:
WriteInterlacedBlock_Vertical:
                or.w    d2,d0
                swap    d0
                btst    #3,(a0)
                bne.s   .flipY
                btst    #2,(a0)
                bne.s   .flipX
                move.l  d0,(a5)
                move.l  (a1)+,(a6)
                rts
; ===========================================================================
; loc_E210:
.flipX:
                move.l  d0,(a5)
                move.l  (a1)+,d3
                eori.l  #(flip_x<<16)|flip_x,d3
                swap    d3
                move.l  d3,(a6)
                rts
; ===========================================================================
; loc_E220:
.flipY:
                btst    #2,(a0)
                bne.s   .flipXY
                move.l  d0,(a5)
                move.l  (a1)+,d3
                eori.l  #(flip_y<<16)|flip_y,d3
                move.l  d3,(a6)
                rts
; ===========================================================================
; loc_E234:
.flipXY:
                move.l  d0,(a5)
                move.l  (a1)+,d3
                eori.l  #((flip_x|flip_y)<<16)|flip_x|flip_y,d3
                swap    d3
                move.l  d3,(a6)
                rts
; End of function WriteInterlacedBlock_Vertical

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E244: GetBlockPtr:
GetBlock:
                add.w   (a3),d5
                add.w   4(a3),d4
                lea     (Block_Table).w,a1
                move.w  d4,d3                           ; d3 = camera Y pos + offset
                add.w   d3,d3
                andi.w  #$F00,d3                        ; limit to units of $100 ($100 = $80 * 2, $80 = height of a 128x128)
                lsr.w   #3,d5                           ; divide by 8
                move.w  d5,d0
                lsr.w   #4,d0                           ; divide by 16 (overall division of 128)
                andi.w  #$7F,d0
                add.w   d3,d0                           ; get offset of current 128x128 in the level layout table
                moveq   #-1,d3
                clr.w   d3                              ; d3 = $FFFF0000
                move.b  (a4,d0.w),d3                    ; get tile ID of the current 128x128 tile
                lsl.w   #7,d3                           ; multiply by 128, the size in bytes of a 128x128 in RAM
                andi.w  #$70,d4                         ; round down to nearest 16-pixel boundary
                andi.w  #$E,d5                          ; force this to be a multiple of 16
                add.w   d4,d3                           ; add vertical offset of current 16x16
                add.w   d5,d3                           ; add horizontal offset of current 16x16
                movea.l d3,a0                           ; store address, in the metablock table, of the current 16x16
                move.w  (a0),d3
                andi.w  #$3FF,d3
                lsl.w   #3,d3
                adda.w  d3,a1
                rts
; End of function GetBlock

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E286: Calc_VRAM_Pos: CalcBlockVRAMPos:
CalculateVRAMAddressOfBlockForPlayer1:
                add.w   (a3),d5                         ; add X pos
; CalcBlockVRAMPos2:
.AbsoluteX:
                tst.w   (Two_player_mode).w
                bne.s   .AbsoluteX_DoubleResolution
                add.w   4(a3),d4                        ; add Y pos
; CalcBlockVRAMPos_NoCamera:
.AbsoluteXAbsoluteY:
                andi.w  #$F0,d4                         ; round down to the nearest 16-pixel boundary
                andi.w  #$1F0,d5                        ; round down to the nearest 16-pixel boundary
                lsl.w   #4,d4                           ; make it into units of $100 - the height in plane A of a 16x16
                lsr.w   #2,d5                           ; make it into units of 4 - the width in plane A of a 16x16
                add.w   d5,d4                           ; combine the two to get final address
; access a VDP address in plane name table A ($C000) or B ($E000) if d2 has bit 13 unset or set
                moveq   #vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE)&$FFFF,d0
                swap    d0
                move.w  d4,d0                           ; make word-swapped VDP command
                rts
; ===========================================================================
; loc_E2A8: CalcBlockVRAMPos_2P:
.AbsoluteX_DoubleResolution:
                add.w   4(a3),d4
; loc_E2AC: CalcBlockVRAMPos_2P_NoCamera:
.AbsoluteXAbsoluteY_DoubleResolution:
                andi.w  #$1F0,d4
                andi.w  #$1F0,d5
                lsl.w   #3,d4
                lsr.w   #2,d5
                add.w   d5,d4
; access a VDP address in plane name table A ($C000) or B ($E000) if d2 has bit 13 unset or set
                moveq   #vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE)&$FFFF,d0
                swap    d0
                move.w  d4,d0
                rts
; End of function CalculateVRAMAddressOfBlockForPlayer1

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_E2C2: CalcBlockVRAMPosB:
CalculateVRAMAddressOfBlockForPlayer2:
                tst.w   (Two_player_mode).w
                bne.s   .doubleResolution

; .regularResolution:
                add.w   4(a3),d4
                add.w   (a3),d5
                andi.w  #$F0,d4
                andi.w  #$1F0,d5
                lsl.w   #4,d4
                lsr.w   #2,d5
                add.w   d5,d4
; access a VDP address in 2p plane name table A ($A000) or B ($8000) if d2 has bit 13 unset or set
                moveq   #vdpComm(VRAM_Plane_A_Name_Table_2P,VRAM,WRITE)&$FFFF,d0
                swap    d0
                move.w  d4,d0
                rts
; ===========================================================================
; This subroutine was in Sonic 1 unused and works by swapping the bottom portion
; of the background's nametable with that of the window plane. This allowed for a
; third scrolling layer (used in the Tokyo Toy Show '90 demo), at the cost of the
; bottom of the background appearing blank
; Now, it is instead used to draw the second player's foreground
.doubleResolution:
                add.w   4(a3),d4
                add.w   (a3),d5
                andi.w  #$1F0,d4
                andi.w  #$1F0,d5
                lsl.w   #3,d4
                lsr.w   #2,d5
                add.w   d5,d4
; access a VDP address in 2p plane name table A ($A000) or B ($8000) if d2 has bit 13 unset or set
                moveq   #vdpComm(VRAM_Plane_A_Name_Table_2P,VRAM,WRITE)&$FFFF,d0
                swap    d0
                move.w  d4,d0
                rts
; End of function CalculateVRAMAddressOfBlockForPlayer2

; ===========================================================================
; Loads the background in its initial state into VRAM (plane B). Especially
; important for levels that never re-load the background dynamically
; See also: DrawLevelTitleCard (loads plane A)
; loc_E300:
DrawInitialBG:
                lea     (VDP_control_port).l,a5
                lea     (VDP_data_port).l,a6
                lea     (Camera_BG_X_pos).w,a3
                lea     (Level_Layout+$80).w,a4         ; background
                move.w  #vdpComm(VRAM_Plane_B_Name_Table,VRAM,WRITE)>>16,d2
; This is a nasty hack to work around the bug described above
                moveq   #0,d4
                cmpi.b  #casino_night_zone,(Current_Zone).w
                beq.w   ++
                tst.w   (Two_player_mode).w
                beq.w   +
                cmpi.b  #mystic_cave_zone,(Current_Zone).w
                beq.w   DrawInitialBG_Full512x512
+
                moveq   #-block_height,d4
+
                moveq   #gameplay_plane_height/block_height-1,d6  ; Height of plane in blocks minus 1
-               movem.l d4-d6,-(sp)
                moveq   #0,d5
                move.w  d4,d1
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  d1,d4
                moveq   #0,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; Width of plane in blocks minus 1
                move    #$2700,sr
                bsr.w   DrawBlockRow_CustomWidth
                move    #$2300,sr
                movem.l (sp)+,d4-d6
                addi.w  #block_height,d4
                dbf     d6,-

                rts
; ===========================================================================
; Dead code for initialising the second player's portion of Plane B
; This was used in earlier builds before title cards were implemented
                moveq   #-block_height,d4

                moveq   #gameplay_plane_height/block_height-1,d6  ; Height of plane in blocks minus 1
-               movem.l d4-d6,-(sp)
                moveq   #0,d5
                move.w  d4,d1
                bsr.w   CalculateVRAMAddressOfBlockForPlayer2
                move.w  d1,d4
                moveq   #0,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; Width of plane in blocks minus 1
                move    #$2700,sr
                bsr.w   DrawBlockRow_CustomWidth
                move    #$2300,sr
                movem.l (sp)+,d4-d6
                addi.w  #block_height,d4
                dbf     d6,-

                rts
; ===========================================================================
; loc_E396:
DrawInitialBG_Full512x512:
; Mystic Cave Zone loads its entire background at once in two player
; mode, since the plane is big enough to fit it, unlike in one player
; mode (512x512 instead of 512x256)
                moveq   #0,d4                           ; Absolute plane Y coordinate

                moveq   #gameplay_plane_height_2p/block_height-1,d6  ; Height of plane in blocks minus 1
-               movem.l d4-d6,-(sp)
                moveq   #0,d5
                move.w  d4,d1
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1.AbsoluteXAbsoluteY_DoubleResolution
                move.w  d1,d4
                moveq   #0,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; Width of plane in blocks minus 1
                move    #$2700,sr
                bsr.w   DrawBlockRow.AbsoluteXAbsoluteYCustomWidth
                move    #$2300,sr
                movem.l (sp)+,d4-d6
                addi.w  #block_height,d4
                dbf     d6,-

                rts
; ===========================================================================
; ===========================================================================

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loadZoneBlockMaps

; Loads block and bigblock mappings for the current Zone
