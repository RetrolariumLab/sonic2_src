DrawBlockColumn_Advanced:
                tst.w   (Two_player_mode).w
                bne.s   .doubleResolution

                moveq   #(1+screen_height/block_height+1)-1,d6  ; Enough blocks to cover the screen, plus one more on the top and bottom
                move.l  #vdpCommDelta(gameplay_plane_width/tile_width*2),d7  ; store VDP command for line increment

-
; If the block is not part of the row that needs updating, then skip
; drawing it
                moveq   #0,d0
                move.b  (a0)+,d0
                btst    d0,(a2)
                beq.s   +

; Get the correct camera and draw this block
                movea.w BGCameraLookup(pc,d0.w),a3      ; Camera, either BG, BG2 or BG3 depending on Y
                movem.l d4-d5/a0,-(sp)
                movem.l d4-d5,-(sp)
                bsr.w   GetBlock
                movem.l (sp)+,d4-d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                bsr.w   ProcessAndWriteBlock_Vertical
                movem.l (sp)+,d4-d5/a0
+
; Move onto the next block down
                addi.w  #block_height,d4
                dbf     d6,-

; Clear the scroll flags now that we're done here
                clr.b   (a2)

                rts
; ===========================================================================

.doubleResolution:
                moveq   #(1+screen_height/block_height+1)-1,d6  ; Enough blocks to cover the screen, plus one more on the top and bottom
                move.l  #vdpCommDelta(gameplay_plane_width/tile_width*2),d7  ; store VDP command for line increment

-
; If the block is not part of the row that needs updating, then skip
; drawing it
                moveq   #0,d0
                move.b  (a0)+,d0
                btst    d0,(a2)
                beq.s   +

; Get the correct camera and draw this block
                movea.w BGCameraLookup(pc,d0.w),a3      ; Camera, either BG, BG2 or BG3 depending on Y
                movem.l d4-d5/a0,-(sp)
                movem.l d4-d5,-(sp)
                bsr.w   GetBlock
                movem.l (sp)+,d4-d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                bsr.w   WriteInterlacedBlock_Vertical
                movem.l (sp)+,d4-d5/a0
+
; Move onto the next block down
                addi.w  #block_height,d4
                dbf     d6,-

; Clear the scroll flags now that we're done here
                clr.b   (a2)

                rts
; End of function Draw_BG3

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DF04: DrawBlockCol1:
DrawBlockColumn:
                moveq   #(1+screen_height/block_height+1)-1,d6  ; Enough blocks to cover the screen, plus one more on the top and bottom
; DrawBlockCol2:
.CustomHeight:
                add.w   (a3),d5                         ; add camera X pos
                add.w   4(a3),d4                        ; add camera Y pos
                move.l  #vdpCommDelta(gameplay_plane_width/tile_width*2),d7  ; store VDP command for line increment
                move.l  d0,d1                           ; copy byte-swapped VDP command for later access
                bsr.w   GetAddressOfBlockInChunk

                tst.w   (Two_player_mode).w
                bne.s   .doubleResolution

-               move.w  (a0),d3                         ; get ID of the 16x16 block
                andi.w  #$3FF,d3
                lsl.w   #3,d3                           ; multiply by 8, the size in bytes of a 16x16
                lea     (Block_Table).w,a1
                adda.w  d3,a1                           ; a1 = address of the current 16x16 in the block table
                move.l  d1,d0
                bsr.w   ProcessAndWriteBlock_Vertical
                adda.w  #chunk_width/block_width*2,a0   ; move onto the 16x16 vertically below this one
                addi.w  #gameplay_plane_width/tile_width*2*2,d1  ; draw on alternate 8x8 lines
                andi.w  #((gameplay_plane_width/tile_width)*(gameplay_plane_height/tile_height)*2)-1,d1  ; wrap around plane (assumed to be in 64x32 mode)
                addi.w  #block_height,d4                ; add 16 to Y offset
                move.w  d4,d0
                andi.w  #$70,d0                         ; have we reached a new 128x128?
                bne.s   +                               ; if not, branch
                bsr.w   GetAddressOfBlockInChunk        ; otherwise, renew the block address
+               dbf     d6,-                            ; repeat 16 times

                rts
; ===========================================================================

.doubleResolution:
-               move.w  (a0),d3
                andi.w  #$3FF,d3
                lsl.w   #3,d3
                lea     (Block_Table).w,a1
                adda.w  d3,a1
                move.l  d1,d0
                bsr.w   WriteInterlacedBlock_Vertical
                adda.w  #chunk_width/block_width*2,a0
                addi.w  #gameplay_plane_width/tile_width*2,d1
                andi.w  #((gameplay_plane_width/tile_width)*(gameplay_plane_height/tile_height)*2)-1,d1
                addi.w  #block_height,d4
                move.w  d4,d0
                andi.w  #$70,d0
                bne.s   +
                bsr.w   GetAddressOfBlockInChunk
+               dbf     d6,-

                rts
; End of function DrawBlockColumn

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DF8A: DrawTiles_Vertical: DrawBlockRow:
DrawBlockRow_CustomWidth:
                add.w   (a3),d5
                add.w   4(a3),d4
                bra.s   DrawBlockRow.AbsoluteXAbsoluteYCustomWidth
; End of function DrawBlockRow_CustomWidth

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DF92: DrawTiles_Vertical1: DrawBlockRow1:
DrawBlockRow:
                moveq   #(1+screen_width/block_width+1)-1,d6  ; Just enough blocks to cover the screen
                add.w   (a3),d5                         ; add X pos
; loc_DF96: DrawTiles_Vertical2: DrawBlockRow2:
.AbsoluteXCustomWidth:
                add.w   4(a3),d4                        ; add Y pos
; loc_DF9A: DrawTiles_Vertical3: DrawBlockRow3:
.AbsoluteXAbsoluteYCustomWidth:
                tst.w   (Two_player_mode).w
                bne.s   .doubleResolution

                move.l  a2,-(sp)
                move.w  d6,-(sp)
                lea     (Block_cache).w,a2
                move.l  d0,d1
                or.w    d2,d1
                swap    d1                              ; make VRAM write command
                move.l  d1,-(sp)
                move.l  d1,(a5)                         ; set up a VRAM write at that address
                swap    d1
                bsr.w   GetAddressOfBlockInChunk

-               move.w  (a0),d3                         ; get ID of the 16x16 block
                andi.w  #$3FF,d3
                lsl.w   #3,d3                           ; multiply by 8, the size in bytes of a 16x16
                lea     (Block_Table).w,a1
                adda.w  d3,a1                           ; a1 = address of current 16x16 in the block table
                bsr.w   ProcessAndWriteBlock_Horizontal
                addq.w  #2,a0                           ; move onto next 16x16
                addq.b  #4,d1                           ; increment VRAM write address
                bpl.s   +
                andi.b  #$7F,d1                         ; restrict to a single 8x8 line
                swap    d1
                move.l  d1,(a5)                         ; set up a VRAM write at a new address
                swap    d1
+
                addi.w  #block_width,d5                 ; add 16 to X offset
                move.w  d5,d0
                andi.w  #$70,d0                         ; have we reached a new 128x128?
                bne.s   +                               ; if not, branch
                bsr.w   GetAddressOfBlockInChunk        ; otherwise, renew the block address
+
                dbf     d6,-                            ; repeat 22 times

                move.l  (sp)+,d1
                addi.l  #vdpCommDelta(gameplay_plane_width/tile_width*2),d1  ; move onto next line
                lea     (Block_cache).w,a2
                move.l  d1,(a5)                         ; write to this VRAM address
                swap    d1
                move.w  (sp)+,d6

-               move.l  (a2)+,(a6)                      ; write stored 8x8s
                addq.b  #4,d1                           ; increment VRAM write address
                bmi.s   +
                ori.b   #$80,d1                         ; force to bottom 8x8 line
                swap    d1
                move.l  d1,(a5)                         ; set up a VRAM write at a new address
                swap    d1
+
                dbf     d6,-                            ; repeat 22 times

                movea.l (sp)+,a2
                rts
; ===========================================================================
; loc_E018: DrawBlockRow_2P:
.doubleResolution:
                move.l  d0,d1
                or.w    d2,d1
                swap    d1
                move.l  d1,(a5)
                swap    d1
                tst.b   d1
                bmi.s   +++

                bsr.w   GetAddressOfBlockInChunk

-               move.w  (a0),d3
                andi.w  #$3FF,d3
                lsl.w   #3,d3
                lea     (Block_Table).w,a1
                adda.w  d3,a1
                bsr.w   WriteInterlacedBlock_Horizontal
                addq.w  #2,a0
                addq.b  #4,d1
                bpl.s   +
                andi.b  #$7F,d1
                swap    d1
                move.l  d1,(a5)
                swap    d1
+
                addi.w  #block_width,d5
                move.w  d5,d0
                andi.w  #$70,d0
                bne.s   +
                bsr.w   GetAddressOfBlockInChunk
+               dbf     d6,-

                rts
; ===========================================================================
+
                bsr.w   GetAddressOfBlockInChunk

-               move.w  (a0),d3
                andi.w  #$3FF,d3
                lsl.w   #3,d3
                lea     (Block_Table).w,a1
                adda.w  d3,a1
                bsr.w   WriteInterlacedBlock_Horizontal
                addq.w  #2,a0
                addq.b  #4,d1
                bmi.s   +
                ori.b   #$80,d1
                swap    d1
                move.l  d1,(a5)
                swap    d1
+
                addi.w  #block_width,d5
                move.w  d5,d0
                andi.w  #$70,d0
                bne.s   +
                bsr.w   GetAddressOfBlockInChunk
+               dbf     d6,-

                rts
; End of function DrawBlockRow

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E09E: GetBlockAddr:
