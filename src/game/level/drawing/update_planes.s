LoadTilesAsYouMove:
                lea     (VDP_control_port).l,a5
                lea     (VDP_data_port).l,a6
                lea     (Scroll_flags_BG_copy).w,a2
                lea     (Camera_BG_copy).w,a3
                lea     (Level_Layout+$80).w,a4         ; first background line
                move.w  #vdpComm(VRAM_Plane_B_Name_Table,VRAM,WRITE)>>16,d2
                bsr.w   Draw_BG1

                lea     (Scroll_flags_BG2_copy).w,a2    ; referred to in CPZ deformation routine, but cleared right after
                lea     (Camera_BG2_copy).w,a3
                bsr.w   Draw_BG2                        ; Essentially unused, though

                lea     (Scroll_flags_BG3_copy).w,a2
                lea     (Camera_BG3_copy).w,a3
                bsr.w   Draw_BG3                        ; used in CPZ deformation routine

                tst.w   (Two_player_mode).w
                beq.s   +
                lea     (Scroll_flags_copy_P2).w,a2
                lea     (Camera_P2_copy).w,a3           ; second player camera
                lea     (Level_Layout).w,a4
                move.w  #vdpComm(VRAM_Plane_A_Name_Table_2P,VRAM,WRITE)>>16,d2
                bsr.w   Draw_FG_P2

+
                lea     (Scroll_flags_copy).w,a2
                lea     (Camera_RAM_copy).w,a3
                lea     (Level_Layout).w,a4
                move.w  #vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE)>>16,d2

                tst.b   (Screen_redraw_flag).w
                beq.s   Draw_FG

                move.b  #0,(Screen_redraw_flag).w

                moveq   #-block_width,d4                ; X (relative to camera)
                moveq   #(1+screen_height/block_height+1)-1,d6  ; Cover the screen, plus an extra row at the top and bottom
; loc_DACE:
Draw_All:
; Redraw the whole screen
                movem.l d4-d6,-(sp)
                moveq   #-block_width,d5                ; X (relative)
                move.w  d4,d1
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  d1,d4
                moveq   #-block_width,d5                ; X (relative)
                bsr.w   DrawBlockRow                    ; draw the current row
                movem.l (sp)+,d4-d6
                addi.w  #block_height,d4                ; move onto the next row
                dbf     d6,Draw_All                     ; repeat for all rows

                move.b  #0,(Scroll_flags_copy).w

                rts
; ===========================================================================
; loc_DAF6:
Draw_FG:
                tst.b   (a2)                            ; is any scroll flag set?
                beq.s   GameLevelDrawingUpdatePlanes_Return  ; if not, branch

                bclr    #scroll_flag_fg_up,(a2)         ; has the level scrolled up?
                beq.s   +                               ; if not, branch
                moveq   #-block_height,d4
                moveq   #-block_width,d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4
                moveq   #-block_width,d5
                bsr.w   DrawBlockRow                    ; redraw upper row
+
                bclr    #scroll_flag_fg_down,(a2)       ; has the level scrolled down?
                beq.s   +                               ; if not, branch
                move.w  #screen_height,d4
                moveq   #-block_width,d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #screen_height,d4
                moveq   #-block_width,d5
                bsr.w   DrawBlockRow                    ; redraw bottom row
+
                bclr    #scroll_flag_fg_left,(a2)       ; has the level scrolled to the left?
                beq.s   +                               ; if not, branch
                moveq   #-block_height,d4
                moveq   #-block_width,d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4
                moveq   #-block_width,d5
                bsr.w   DrawBlockColumn                 ; redraw left-most column
+
                bclr    #scroll_flag_fg_right,(a2)      ; has the level scrolled to the right?
                beq.s   GameLevelDrawingUpdatePlanes_Return  ; if not, return
                moveq   #-block_height,d4
                move.w  #screen_width,d5
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4
                move.w  #screen_width,d5
                bsr.w   DrawBlockColumn                 ; redraw right-most column

GameLevelDrawingUpdatePlanes_Return:
                rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DB5C:
Draw_FG_P2:
                tst.b   (a2)
                beq.s   GameLevelDrawingUpdatePlanes_Return_Variant2

                bclr    #scroll_flag_fg_up,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer2
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockRow
+
                bclr    #scroll_flag_fg_down,(a2)
                beq.s   +
                move.w  #screen_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer2
                move.w  #screen_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockRow
+
                bclr    #scroll_flag_fg_left,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer2
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockColumn
+
                bclr    #scroll_flag_fg_right,(a2)
                beq.s   GameLevelDrawingUpdatePlanes_Return_Variant2
                moveq   #-block_height,d4               ; Y offset
                move.w  #screen_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer2
                moveq   #-block_height,d4               ; Y offset
                move.w  #screen_width,d5                ; X offset
                bsr.w   DrawBlockColumn

GameLevelDrawingUpdatePlanes_Return_Variant2:
                rts
; End of function Draw_FG_P2

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DBC2:
Draw_BG1:
                tst.b   (a2)
                beq.w   GameLevelDrawingUpdatePlanes_Return_Variant3

                bclr    #scroll_flag_bg1_up,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockRow
+
                bclr    #scroll_flag_bg1_down,(a2)
                beq.s   +
                move.w  #screen_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #screen_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockRow
+
                bclr    #scroll_flag_bg1_left,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4               ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   DrawBlockColumn
+
                bclr    #scroll_flag_bg1_right,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                move.w  #screen_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4               ; Y offset
                move.w  #screen_width,d5                ; X offset
                bsr.w   DrawBlockColumn
+
                bclr    #scroll_flag_bg1_up_whole_row,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset
                moveq   #0,d5                           ; X (absolute)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1.AbsoluteX
                moveq   #-block_height,d4
                moveq   #0,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; The entire width of the plane in blocks minus 1
                bsr.w   DrawBlockRow.AbsoluteXCustomWidth
+
                bclr    #scroll_flag_bg1_down_whole_row,(a2)
                beq.s   +
                move.w  #screen_height,d4               ; Y offset
                moveq   #0,d5                           ; X (absolute)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1.AbsoluteX
                move.w  #screen_height,d4
                moveq   #0,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; The entire width of the plane in blocks minus 1
                bsr.w   DrawBlockRow.AbsoluteXCustomWidth
+
; This should be no different than 'scroll_flag_bg1_up_whole_row'
; The only difference between the two is that this has a relative X
; coordinate, but that doesn't matter since the entire row is copied
; anyway
                bclr    #scroll_flag_bg1_up_whole_row_2,(a2)
                beq.s   +
                moveq   #-block_height,d4               ; Y offset (relative to camera)
                moveq   #-block_width,d5                ; X offset (relative to camera)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                moveq   #-block_height,d4
                moveq   #-block_width,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; The entire width of the plane in blocks minus 1
                bsr.w   DrawBlockRow_CustomWidth
+
; This should be no different than 'scroll_flag_bg1_down_whole_row'
; The only difference between the two is that this has a relative X
; coordinate, but that doesn't matter since the entire row is copied
; anyway
                bclr    #scroll_flag_bg1_down_whole_row_2,(a2)
                beq.s   GameLevelDrawingUpdatePlanes_Return_Variant3
                move.w  #screen_height,d4               ; Y offset (relative to camera)
                moveq   #-block_width,d5                ; X offset (relative to camera)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #screen_height,d4
                moveq   #-block_width,d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; The entire width of the plane in blocks minus 1
                bsr.w   DrawBlockRow_CustomWidth

GameLevelDrawingUpdatePlanes_Return_Variant3:
                rts
; End of function Draw_BG1

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DC92:
Draw_BG2:
                tst.b   (a2)
                beq.w   ++                              ; rts

; Leftover from Sonic 1: was used by Green Hill Zone and Spring Yard Zone
                bclr    #scroll_flag_bg2_left,(a2)
                beq.s   +
                move.w  #block_height*7,d4              ; Y offset
                moveq   #-block_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #block_height*7,d4              ; Y offset
                moveq   #-block_width,d5                ; X offset
                moveq   #3-1,d6                         ; Only three blocks, which works out to 48 pixels in height
                bsr.w   DrawBlockColumn.CustomHeight
+
                bclr    #scroll_flag_bg2_right,(a2)
                beq.s   +
                move.w  #block_height*7,d4              ; Y offset
                move.w  #screen_width,d5                ; X offset
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #block_height*7,d4              ; Y offset
                move.w  #screen_width,d5                ; X offset
                moveq   #3-1,d6                         ; Only three blocks, which works out to 48 pixels in height
                bsr.w   DrawBlockColumn.CustomHeight
+
                rts
; End of function Draw_BG2

; ===========================================================================
; Scrap Brain Zone 1 block positioning array -- S1 left-over
; Each entry is an index into BGCameraLookup; used to decide the camera to use
; for given block for reloading BG. A entry of 0 means assume X = 0 for section,
; but otherwise loads camera Y for selected camera
; Note that this list is 32 blocks long, which is enough to span the entire
; two-chunk-tall background
; byte_DCD6
SBZ_CameraSections:
; BG1 (draw whole row)
                dc.b    0                               ; 0
                dc.b    0                               ; 1
                dc.b    0                               ; 2
                dc.b    0                               ; 3
                dc.b    0                               ; 4
; BG3
                dc.b    6                               ; 5
                dc.b    6                               ; 6
                dc.b    6                               ; 7
                dc.b    6                               ; 8
                dc.b    6                               ; 9
                dc.b    6                               ; 10
                dc.b    6                               ; 11
                dc.b    6                               ; 12
                dc.b    6                               ; 13
                dc.b    6                               ; 14
; BG2
                dc.b    4                               ; 15
                dc.b    4                               ; 16
                dc.b    4                               ; 17
                dc.b    4                               ; 18
                dc.b    4                               ; 19
                dc.b    4                               ; 20
                dc.b    4                               ; 21
; BG1
                dc.b    2                               ; 22
                dc.b    2                               ; 23
                dc.b    2                               ; 24
                dc.b    2                               ; 25
                dc.b    2                               ; 26
                dc.b    2                               ; 27
                dc.b    2                               ; 28
                dc.b    2                               ; 29
                dc.b    2                               ; 30
                dc.b    2                               ; 31
                dc.b    2                               ; 32

; Total height: 2 256x256 chunks
; This matches the height of the background

                even

; ===========================================================================
; Scrap Brain Zone 1 drawing code -- Sonic 1 left-over

; Draw_BG2_SBZ:
; Chemical Plant Zone uses a lighty-modified version this code
; This is an advanced form of the usual background-drawing code that
; allows each row of blocks to update and scroll independently
; kind of. There are only three possible 'cameras' that each row can
; align itself with. Still, each row is free to decide which camera
; it aligns with
; This could have really benefitted Oil Ocean Zone's background,
; which has a section that goes unseen because the regular background
; drawer is too primitive to display it without making the sun and
; clouds disappear. Using this would have avoided that

; Handle loading the rows as the camera moves up and down
                moveq   #-block_height,d4               ; Y offset (relative to camera)
                bclr    #scroll_flag_advanced_bg_up,(a2)
                bne.s   .doUpOrDown
                bclr    #scroll_flag_advanced_bg_down,(a2)
                beq.s   .checkIfShouldDoLeftOrRight
                move.w  #screen_height,d4               ; Y offset (relative to camera)

.doUpOrDown:
                lea_    SBZ_CameraSections+1,a0
                move.w  (Camera_BG_Y_pos).w,d0
                add.w   d4,d0
                andi.w  #$1F0,d0                        ; After right-shifting, the is a mask of $1F. Since SBZ_CameraSections is $20 items long, this is correct
                lsr.w   #4,d0
                move.b  (a0,d0.w),d0
                lea     (BGCameraLookup).l,a3
                movea.w (a3,d0.w),a3                    ; Camera, either BG, BG2 or BG3 depending on Y
                beq.s   .doWholeRow
                moveq   #-block_width,d5                ; X offset (relative to camera)
                movem.l d4-d5,-(sp)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                movem.l (sp)+,d4-d5
                bsr.w   DrawBlockRow
                bra.s   .checkIfShouldDoLeftOrRight
; ===========================================================================

.doWholeRow:
                moveq   #0,d5                           ; X (absolute)
                movem.l d4-d5,-(sp)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1.AbsoluteX
                movem.l (sp)+,d4-d5
                moveq   #gameplay_plane_width/block_width-1,d6  ; The entire width of the plane in blocks minus 1
                bsr.w   DrawBlockRow.AbsoluteXCustomWidth

.checkIfShouldDoLeftOrRight:
; If there are other scroll flags set, then go do them
                tst.b   (a2)
                bne.s   .doLeftOrRight
                rts
; ===========================================================================

.doLeftOrRight:
                moveq   #-block_height,d4               ; Y offset

; Load left column
                moveq   #-block_width,d5                ; X offset
                move.b  (a2),d0
                andi.b  #(1<<scroll_flag_advanced_bg1_right)|(1<<scroll_flag_advanced_bg2_right)|(1<<scroll_flag_advanced_bg3_right),d0
                beq.s   +
                lsr.b   #1,d0                           ; Make the left and right flags share the same bits, to simplify a calculation later
                move.b  d0,(a2)
; Load right column
                move.w  #screen_width,d5                ; X offset
+
; Select the correct starting background section, and then begin
; drawing the column
                lea_    SBZ_CameraSections,a0
                move.w  (Camera_BG_Y_pos).w,d0
                andi.w  #$1F0,d0                        ; After right-shifting, the is a mask of $1F. Since SBZ_CameraSections is $20 items long, this is correct
                lsr.w   #4,d0
                lea     (a0,d0.w),a0
                bra.w   DrawBlockColumn_Advanced
; end unused routine

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_DD82:
Draw_BG3:
                tst.b   (a2)
                beq.w   ++                              ; rts

                cmpi.b  #chemical_plant_zone,(Current_Zone).w
                beq.w   Draw_BG3_CPZ

; Leftover from Sonic 1: was used by Green Hill Zone
                bclr    #scroll_flag_bg3_left,(a2)
                beq.s   +
                move.w  #block_height*4,d4              ; Y offset (relative to camera)
                moveq   #-block_width,d5                ; X offset (relative to camera)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #block_height*4,d4              ; Y offset (relative to camera)
                moveq   #-block_width,d5                ; X offset (relative to camera)
                moveq   #3-1,d6
                bsr.w   DrawBlockColumn.CustomHeight
+
                bclr    #scroll_flag_bg3_right,(a2)
                beq.s   +
                move.w  #block_height*4,d4              ; Y offset (relative to camera)
                move.w  #screen_width,d5                ; X offset (relative to camera)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                move.w  #block_height*4,d4              ; Y offset (relative to camera)
                move.w  #screen_width,d5                ; X offset (relative to camera)
                moveq   #3-1,d6
                bsr.w   DrawBlockColumn.CustomHeight
+
                rts
; ===========================================================================
; Chemical Plant Zone block positioning array
; Each entry is an index into BGCameraLookup; used to decide the camera to use
; for given block for reloading BG. Unlike the Scrap Brain Zone version, 0
; does not make X = 0: it's just a duplicate of 2
; byte_DDD0
CPZ_CameraSections:
; BG1
                dc.b    2                               ; 0
                dc.b    2                               ; 1
                dc.b    2                               ; 2
                dc.b    2                               ; 3
                dc.b    2                               ; 4
                dc.b    2                               ; 5
                dc.b    2                               ; 6
                dc.b    2                               ; 7
                dc.b    2                               ; 8
                dc.b    2                               ; 9
                dc.b    2                               ; 10
                dc.b    2                               ; 11
                dc.b    2                               ; 12
                dc.b    2                               ; 13
                dc.b    2                               ; 14
                dc.b    2                               ; 15
                dc.b    2                               ; 16
                dc.b    2                               ; 17
                dc.b    2                               ; 18
                dc.b    2                               ; 19
; BG2
                dc.b    4                               ; 20
                dc.b    4                               ; 21
                dc.b    4                               ; 22
                dc.b    4                               ; 23
                dc.b    4                               ; 24
                dc.b    4                               ; 25
                dc.b    4                               ; 26
                dc.b    4                               ; 27
                dc.b    4                               ; 28
                dc.b    4                               ; 29
                dc.b    4                               ; 30
                dc.b    4                               ; 31
                dc.b    4                               ; 32
                dc.b    4                               ; 33
                dc.b    4                               ; 34
                dc.b    4                               ; 35
                dc.b    4                               ; 36
                dc.b    4                               ; 37
                dc.b    4                               ; 38
                dc.b    4                               ; 39
                dc.b    4                               ; 40
                dc.b    4                               ; 41
                dc.b    4                               ; 42
                dc.b    4                               ; 43
                dc.b    4                               ; 44
                dc.b    4                               ; 45
                dc.b    4                               ; 46
                dc.b    4                               ; 47
                dc.b    4                               ; 48
                dc.b    4                               ; 49
                dc.b    4                               ; 50
                dc.b    4                               ; 51
                dc.b    4                               ; 52
                dc.b    4                               ; 53
                dc.b    4                               ; 54
                dc.b    4                               ; 55
                dc.b    4                               ; 56
                dc.b    4                               ; 57
                dc.b    4                               ; 58
                dc.b    4                               ; 59
                dc.b    4                               ; 60
                dc.b    4                               ; 61
                dc.b    4                               ; 62
                dc.b    4                               ; 63
                dc.b    4                               ; 64

; Total height: 8 128x128 chunks
; CPZ's background is only 7 chunks tall, but extending to
; 8 is necessary for wrapping to be achieved using bitmasks

                even

; ===========================================================================
; loc_DE12:
Draw_BG3_CPZ:
; This is a lighty-modified duplicate of Scrap Brain Zone's drawing
; code (which is still in this game - it's labelled 'Draw_BG2_SBZ')
; This is an advanced form of the usual background-drawing code that
; allows each row of blocks to update and scroll independently
; kind of. There are only three possible 'cameras' that each row can
; align itself with. Still, each row is free to decide which camera
; it aligns with
; This could have really benefitted Oil Ocean Zone's background,
; which has a section that goes unseen because the regular background
; drawer is too primitive to display it without making the sun and
; clouds disappear. Using this would have avoided that
; This code differs from the Scrap Brain Zone version by being
; hardcoded to a different table ('CPZ_CameraSections' instead of
; 'SBZ_CameraSections'), and lacking support for redrawing the whole
; row when it uses "camera 0"

; Handle loading the rows as the camera moves up and down
                moveq   #-block_height,d4               ; Y offset
                bclr    #scroll_flag_advanced_bg_up,(a2)
                bne.s   .doUpOrDown
                bclr    #scroll_flag_advanced_bg_down,(a2)
                beq.s   .checkIfShouldDoLeftOrRight
                move.w  #screen_height,d4               ; Y offset

.doUpOrDown:
; Select the correct camera, so that the X value of the loaded row is
; right
                lea_    CPZ_CameraSections+1,a0
                move.w  (Camera_BG_Y_pos).w,d0
                add.w   d4,d0
                andi.w  #$3F0,d0                        ; After right-shifting, the is a mask of $3F. Since CPZ_CameraSections is $40 items long, this is correct
                lsr.w   #4,d0
                move.b  (a0,d0.w),d0
                movea.w BGCameraLookup(pc,d0.w),a3      ; Camera, either BG, BG2 or BG3 depending on Y
                moveq   #-block_width,d5                ; X offset
                movem.l d4-d5,-(sp)
                bsr.w   CalculateVRAMAddressOfBlockForPlayer1
                movem.l (sp)+,d4-d5
                bsr.w   DrawBlockRow

.checkIfShouldDoLeftOrRight:
; If there are other scroll flags set, then go do them
                tst.b   (a2)
                bne.s   .doLeftOrRight
                rts
; ===========================================================================

.doLeftOrRight:
                moveq   #-block_height,d4               ; Y offset

; Load left column
                moveq   #-block_width,d5                ; X offset
                move.b  (a2),d0
                andi.b  #(1<<scroll_flag_advanced_bg1_right)|(1<<scroll_flag_advanced_bg2_right)|(1<<scroll_flag_advanced_bg3_right),d0
                beq.s   +
                lsr.b   #1,d0                           ; Make the left and right flags share the same bits, to simplify a calculation later
                move.b  d0,(a2)
; Load right column
                move.w  #screen_width,d5                ; X offset
+
; Select the correct starting background section, and then begin
; drawing the column
                lea_    CPZ_CameraSections,a0
                move.w  (Camera_BG_Y_pos).w,d0
; After right-shifting, the is a mask of $7F. Since CPZ_CameraSections
; is $40 items long, this is incorrect, and will cause accesses to
; exceed the bounds of CPZ_CameraSections and read invalid data. This
; is most notably a problem in Marble Zone's version of this code
                andi.w  #$7F0,d0
                lsr.w   #4,d0
                lea     (a0,d0.w),a0
                bra.w   DrawBlockColumn_Advanced
; ===========================================================================
; word_DE7E
BGCameraLookup:
                dc.w    Camera_BG_copy                  ; BG Camera
                dc.w    Camera_BG_copy                  ; BG Camera
                dc.w    Camera_BG2_copy                 ; BG2 Camera
                dc.w    Camera_BG3_copy                 ; BG3 Camera
; ===========================================================================
; loc_DE86:
