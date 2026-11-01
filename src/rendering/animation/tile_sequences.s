Dynamic_Normal:
                lea     (Anim_Counters).w,a3
; loc_3FF30:
.customCounters:
                move.w  (a2)+,d6                        ; Get number of scripts in list
; S&K checks for empty lists, here
; bpl.s .listnotempty ; If there are any, continue
; rts
; .listnotempty:

; loc_3FF32:
.loop:
                subq.b  #1,(a3)                         ; Tick down frame duration
                bcc.s   .nextscript                     ; If frame isn't over, move on to next script

; .nextframe:
                moveq   #0,d0
                move.b  1(a3),d0                        ; Get current frame
                cmp.b   6(a2),d0                        ; Have we processed the last frame in the script?
                blo.s   .notlastframe
                moveq   #0,d0                           ; If so, reset to first frame
                move.b  d0,1(a3)                        ; ''
; loc_3FF48:
.notlastframe:
                addq.b  #1,1(a3)                        ; Consider this frame processed; set counter to next frame
                move.b  (a2),(a3)                       ; Set frame duration to global duration value
                bpl.s   .globalduration
; If script uses per-frame durations, use those instead
                add.w   d0,d0
                move.b  9(a2,d0.w),(a3)                 ; Set frame duration to current frame's duration value
; loc_3FF56:
.globalduration:
; Prepare for DMA transfer
; Get relative address of frame's art
                move.b  8(a2,d0.w),d0                   ; Get tile ID
                lsl.w   #5,d0                           ; Turn it into an offset
; Get VRAM destination address
                move.w  4(a2),d2
; Get ROM source address
                move.l  (a2),d1                         ; Get start address of animated tile art
                andi.l  #$FFFFFF,d1
                add.l   d0,d1                           ; Offset into art, to get the address of new frame
; Get size of art to be transferred
                moveq   #0,d3
                move.b  7(a2),d3
                lsl.w   #4,d3                           ; Turn it into actual size (in words)
; Use d1, d2 and d3 to queue art for transfer
                jsr     (QueueDMATransfer).l
; loc_3FF78:
.nextscript:
                move.b  6(a2),d0                        ; Get total size of frame data
                tst.b   (a2)                            ; Is per-frame duration data present?
                bpl.s   .globalduration2                ; If not, keep the current size; it's correct
                add.b   d0,d0                           ; Double size to account for the additional frame duration data
; loc_3FF82:
.globalduration2:
                addq.b  #1,d0
                andi.w  #$FE,d0                         ; Round to next even address, if it isn't already
                lea     8(a2,d0.w),a2                   ; Advance to next script in list
                addq.w  #2,a3                           ; Advance to next script's slot in a3 (usually Anim_Counters)
                dbf     d6,.loop
                rts
; ===========================================================================
; ZONE ANIMATION SCRIPTS
;
; The Dynamic_Normal subroutine uses these scripts to reload certain tiles,
; thus animating them. All the relevant art must be uncompressed, because
; otherwise the subroutine would spend so much time waiting for the art to be
; decompressed that the VBLANK window would close before all the animating was done

; zoneanimdecl -1, ArtUnc_Flowers1, ArtTile_ArtUnc_Flowers1, 6, 2
; -1   Global frame duration. If -1, then each frame will use its own duration, instead
; ArtUnc_Flowers1  Source address
; ArtTile_ArtUnc_Flowers1 Destination VRAM address
; 6   Number of frames
; 2   Number of tiles to load into VRAM for each frame

; dc.b   0,$7F  ; Start of the script proper
; 0   Tile ID of first tile in ArtUnc_Flowers1 to transfer
; $7F   Frame duration. Only here if global duration is -1

; loc_3FF94:
Animated_EHZ:   zoneanimstart
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers1, ArtTile_ArtUnc_Flowers1, 6, 2
                dc.b    0,$7F                           ; Start of the script proper
                dc.b    2,$13
                dc.b    0,  7
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2,  7
                even
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers2, ArtTile_ArtUnc_Flowers2, 8, 2
                dc.b    2,$7F
                dc.b    0, $B
                dc.b    2, $B
                dc.b    0, $B
                dc.b    2,  5
                dc.b    0,  5
                dc.b    2,  5
                dc.b    0,  5
                even
; Flowers
                zoneanimdecl 7, ArtUnc_Flowers3, ArtTile_ArtUnc_Flowers3, 2, 2
                dc.b    0
                dc.b    2
                even
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers4, ArtTile_ArtUnc_Flowers4, 8, 2
                dc.b    0,$7F
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2, $B
                dc.b    0, $B
                dc.b    2, $B
                even
; Pulsing thing against checkered background
                zoneanimdecl -1, ArtUnc_EHZPulseBall, ArtTile_ArtUnc_EHZPulseBall, 6, 2
                dc.b    0,$17
                dc.b    2,  9
                dc.b    4, $B
                dc.b    6,$17
                dc.b    4, $B
                dc.b    2,  9
                even

                zoneanimend

Animated_MTZ:   zoneanimstart
; Spinning metal cylinder
                zoneanimdecl 0, ArtUnc_MTZCylinder, ArtTile_ArtUnc_MTZCylinder, 8,$10
                dc.b    0
                dc.b    $10
                dc.b    $20
                dc.b    $30
                dc.b    $40
                dc.b    $50
                dc.b    $60
                dc.b    $70
                even
; lava
                zoneanimdecl $D, ArtUnc_Lava, ArtTile_ArtUnc_Lava, 6,$C
                dc.b    0
                dc.b    $C
                dc.b    $18
                dc.b    $24
                dc.b    $18
                dc.b    $C
                even
; MTZ background animated section
                zoneanimdecl -1, ArtUnc_MTZAnimBack, ArtTile_ArtUnc_MTZAnimBack_1, 4, 6
                dc.b    0,$13
                dc.b    6,  7
                dc.b    $C,$13
                dc.b    6,  7
                even
; MTZ background animated section
                zoneanimdecl -1, ArtUnc_MTZAnimBack, ArtTile_ArtUnc_MTZAnimBack_2, 4, 6
                dc.b    $C,$13
                dc.b    6,  7
                dc.b    0,$13
                dc.b    6,  7
                even

                zoneanimend

Animated_HTZ:   zoneanimstart
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers1, ArtTile_ArtUnc_Flowers1, 6, 2
                dc.b    0,$7F
                dc.b    2,$13
                dc.b    0,  7
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2,  7
                even
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers2, ArtTile_ArtUnc_Flowers2, 8, 2
                dc.b    2,$7F
                dc.b    0, $B
                dc.b    2, $B
                dc.b    0, $B
                dc.b    2,  5
                dc.b    0,  5
                dc.b    2,  5
                dc.b    0,  5
                even
; Flowers
                zoneanimdecl 7, ArtUnc_Flowers3, ArtTile_ArtUnc_Flowers3, 2, 2
                dc.b    0
                dc.b    2
                even
; Flowers
                zoneanimdecl -1, ArtUnc_Flowers4, ArtTile_ArtUnc_Flowers4, 8, 2
                dc.b    0,$7F
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2,  7
                dc.b    0,  7
                dc.b    2, $B
                dc.b    0, $B
                dc.b    2, $B
                even
; Pulsing thing against checkered background
                zoneanimdecl -1, ArtUnc_EHZPulseBall, ArtTile_ArtUnc_EHZPulseBall, 6, 2
                dc.b    0,$17
                dc.b    2,  9
                dc.b    4, $B
                dc.b    6,$17
                dc.b    4, $B
                dc.b    2,  9
                even

                zoneanimend

; word_4009C: Animated_OOZ:
Animated_HPZ:   zoneanimstart
; Supposed to be the pulsing orb from HPZ, but uses OOZ's pulsing ball art
                zoneanimdecl 8, ArtUnc_HPZPulseOrb, ArtTile_ArtUnc_HPZPulseOrb_1, 6, 8
                dc.b    0
                dc.b    0
                dc.b    8
                dc.b    $10
                dc.b    $10
                dc.b    8
                even
; Supposed to be the pulsing orb from HPZ, but uses OOZ's pulsing ball art
                zoneanimdecl 8, ArtUnc_HPZPulseOrb, ArtTile_ArtUnc_HPZPulseOrb_2, 6, 8
                dc.b    8
                dc.b    $10
                dc.b    $10
                dc.b    8
                dc.b    0
                dc.b    0
                even
; Supposed to be the pulsing orb from HPZ, but uses OOZ's pulsing ball art
                zoneanimdecl 8, ArtUnc_HPZPulseOrb, ArtTile_ArtUnc_HPZPulseOrb_3, 6, 8
                dc.b    $10
                dc.b    8
                dc.b    0
                dc.b    0
                dc.b    8
                dc.b    $10
                even

                zoneanimend

; word_400C8:  Animated_OOZ2:
Animated_OOZ:   zoneanimstart
; Pulsing ball from OOZ
                zoneanimdecl -1, ArtUnc_OOZPulseBall, ArtTile_ArtUnc_OOZPulseBall, 4, 4
                dc.b    0, $B
                dc.b    4,  5
                dc.b    8,  9
                dc.b    4,  3
                even
; Square rotating around ball in OOZ
                zoneanimdecl 6, ArtUnc_OOZSquareBall1, ArtTile_ArtUnc_OOZSquareBall1, 4, 4
                dc.b    0
                dc.b    4
                dc.b    8
                dc.b    $C
                even
; Square rotating around ball
                zoneanimdecl 6, ArtUnc_OOZSquareBall2, ArtTile_ArtUnc_OOZSquareBall2, 4, 4
                dc.b    0
                dc.b    4
                dc.b    8
                dc.b    $C
                even
; Oil
                zoneanimdecl $11, ArtUnc_Oil1, ArtTile_ArtUnc_Oil1, 6,$10
                dc.b    0
                dc.b    $10
                dc.b    $20
                dc.b    $30
                dc.b    $20
                dc.b    $10
                even
; Oil
                zoneanimdecl $11, ArtUnc_Oil2, ArtTile_ArtUnc_Oil2, 6,$10
                dc.b    0
                dc.b    $10
                dc.b    $20
                dc.b    $30
                dc.b    $20
                dc.b    $10
                even

                zoneanimend

Animated_CNZ:   zoneanimstart
; Flipping foreground section in CNZ
                zoneanimdecl -1, ArtUnc_CNZFlipTiles, ArtTile_ArtUnc_CNZFlipTiles_2, $10,$10
                dc.b    0,$C7
                dc.b    $10,  5
                dc.b    $20,  5
                dc.b    $30,  5
                dc.b    $40,$C7
                dc.b    $50,  5
                dc.b    $20,  5
                dc.b    $60,  5
                dc.b    0,  5
                dc.b    $10,  5
                dc.b    $20,  5
                dc.b    $30,  5
                dc.b    $40,  5
                dc.b    $50,  5
                dc.b    $20,  5
                dc.b    $60,  5
                even
; Flipping foreground section in CNZ
                zoneanimdecl -1, ArtUnc_CNZFlipTiles, ArtTile_ArtUnc_CNZFlipTiles_1, $10,$10
                dc.b    $70,  5
                dc.b    $80,  5
                dc.b    $20,  5
                dc.b    $90,  5
                dc.b    $A0,  5
                dc.b    $B0,  5
                dc.b    $20,  5
                dc.b    $C0,  5
                dc.b    $70,$C7
                dc.b    $80,  5
                dc.b    $20,  5
                dc.b    $90,  5
                dc.b    $A0,$C7
                dc.b    $B0,  5
                dc.b    $20,  5
                dc.b    $C0,  5
                even

                zoneanimend

; word_40160:
Animated_CNZ_2P:    zoneanimstart
; Flipping foreground section in CNZ
                zoneanimdecl -1, ArtUnc_CNZFlipTiles, ArtTile_ArtUnc_CNZFlipTiles_2_2p, $10,$10
                dc.b    0,$C7
                dc.b    $10,  5
                dc.b    $20,  5
                dc.b    $30,  5
                dc.b    $40,$C7
                dc.b    $50,  5
                dc.b    $20,  5
                dc.b    $60,  5
                dc.b    0,  5
                dc.b    $10,  5
                dc.b    $20,  5
                dc.b    $30,  5
                dc.b    $40,  5
                dc.b    $50,  5
                dc.b    $20,  5
                dc.b    $60,  5
                even
; Flipping foreground section in CNZ
                zoneanimdecl -1, ArtUnc_CNZFlipTiles, ArtTile_ArtUnc_CNZFlipTiles_1_2p, $10,$10
                dc.b    $70,  5
                dc.b    $80,  5
                dc.b    $20,  5
                dc.b    $90,  5
                dc.b    $A0,  5
                dc.b    $B0,  5
                dc.b    $20,  5
                dc.b    $C0,  5
                dc.b    $70,$C7
                dc.b    $80,  5
                dc.b    $20,  5
                dc.b    $90,  5
                dc.b    $A0,$C7
                dc.b    $B0,  5
                dc.b    $20,  5
                dc.b    $C0,  5
                even

                zoneanimend

Animated_CPZ:   zoneanimstart
; Animated background section in CPZ and DEZ
                zoneanimdecl 4, ArtUnc_CPZAnimBack, ArtTile_ArtUnc_CPZAnimBack, 8, 2
                dc.b    0
                dc.b    2
                dc.b    4
                dc.b    6
                dc.b    8
                dc.b    $A
                dc.b    $C
                dc.b    $E
                even

                zoneanimend

Animated_DEZ:   zoneanimstart
; Animated background section in CPZ and DEZ
                zoneanimdecl 4, ArtUnc_CPZAnimBack, ArtTile_ArtUnc_DEZAnimBack, 8, 2
                dc.b    0
                dc.b    2
                dc.b    4
                dc.b    6
                dc.b    8
                dc.b    $A
                dc.b    $C
                dc.b    $E
                even

                zoneanimend

Animated_ARZ:   zoneanimstart
; Waterfall patterns
                zoneanimdecl 5, ArtUnc_Waterfall1, ArtTile_ArtUnc_Waterfall1_2, 2, 4
                dc.b    0
                dc.b    4
                even
; Waterfall patterns
                zoneanimdecl 5, ArtUnc_Waterfall1, ArtTile_ArtUnc_Waterfall1_1, 2, 4
                dc.b    4
                dc.b    0
                even
; Waterfall patterns
                zoneanimdecl 5, ArtUnc_Waterfall2, ArtTile_ArtUnc_Waterfall2, 2, 4
                dc.b    0
                dc.b    4
                even
; Waterfall patterns
                zoneanimdecl 5, ArtUnc_Waterfall3, ArtTile_ArtUnc_Waterfall3, 2, 4
                dc.b    0
                dc.b    4
                even

                zoneanimend

Animated_Null:
; invalid
; ===========================================================================

; ---------------------------------------------------------------------------
; Unused mystery function
; In CPZ, within a certain range of camera X coordinates spanning
; exactly 2 screens (a boss fight or cutscene?),
; once every 8 frames, make the entire screen refresh and do... SOMETHING
; (in 2 separate 512-byte blocks of memory, move around a bunch of bytes)
; Maybe some abandoned scrolling effect?
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_40200:
                cmpi.b  #chemical_plant_zone,(Current_Zone).w
                beq.s   +
-               rts
; ===========================================================================
; this shifts all blocks of the chunks $EA-$ED and $FA-$FD one block to the
; left and the last block in each row (chunk $ED/$FD) to the beginning
; i.e. rotates the blocks to the left by one
+
                move.w  (Camera_X_pos).w,d0
                cmpi.w  #$1940,d0
                blo.s   -                               ; rts
                cmpi.w  #$1F80,d0
                bhs.s   -                               ; rts
                subq.b  #1,(CPZ_UnkScroll_Timer).w
                bpl.s   -                               ; rts ; do it every 8th frame
                move.b  #7,(CPZ_UnkScroll_Timer).w
                move.b  #1,(Screen_redraw_flag).w
                lea     (Chunk_Table+$EA*$80).l,a1      ; chunks $EA-$ED, $FFFF7500 - $FFFF7700
                bsr.s   +
                lea     (Chunk_Table+$FA*$80).l,a1      ; chunks $FA-$FD, $FFFF7D00 - $FFFF7F00
+
                move.w  #8-1,d1

-               move.w  (a1),d0
                rept    3                               ; do this for 3 chunks
                rept    7
                move.w  2(a1),(a1)+                     ; shift 1st line of chunk by 1 block to the left (+3*14 bytes)
                endm
                move.w  $72(a1),(a1)+                   ; first block of next chunk to the left into previous chunk (+3*2 bytes)
                adda.w  #$70,a1                         ; go to next chunk (+336 bytes)
                endm
                rept    7                               ; now do it for the 4th chunk
                move.w  2(a1),(a1)+                     ; shift 1st line of chunk by 1 block to the left (+14 bytes)
                endm
                move.w  d0,(a1)+                        ; move 1st block of 1st chunk to last block of last chunk (+2 bytes, subsubtotal = 400 bytes)
                suba.w  #$180,a1                        ; go to the next row in the first chunk (-384 bytes, subtotal = -16 bytes)
                dbf     d1,-                            ; now do this again for rows 2-8 in these chunks
    ; 400 + 7 * (-16) = 512 byte range was affected
                rts
; ===========================================================================
; loc_402D4:
