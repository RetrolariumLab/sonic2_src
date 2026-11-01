ChkDrawSprite_2P:
; This branch skips the X-flip and Y-flip checks, causing
; multi-sprite objects to not properly mirror in two player mode
; An easy place to see this is Mystic Case Zone: the Crawltons
; badnik's body segments will always face in one direction, and only
; the head will be properly flipped
                cmpi.b  #80,d5
                blo.s   DrawSprite_2P_Loop
                rts
; End of function ChkDrawSprite_2P

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; copy sprite art to VRAM, in 2-player mode

; sub_16DAE:
DrawSprite_2P:
                movea.w art_tile(a0),a3
; This check has been moved, so it is redundant
; See the bugfix under 'DrawSprite_Loop'
                cmpi.b  #80,d5
                bhs.s   DrawSprite_2P_Done
                btst    #0,d4
                bne.s   DrawSprite_2P_FlipX
                btst    #1,d4
                bne.w   DrawSprite_2P_FlipY
; loc_16DC6:
DrawSprite_2P_Loop:
                move.b  (a1)+,d0
                ext.w   d0
                add.w   d2,d0
                move.w  d0,(a2)+
                move.b  (a1)+,d4
                move.b  SpriteSizes_2P(pc,d4.w),(a2)+
                addq.b  #1,d5
                move.b  d5,(a2)+
                addq.w  #2,a1
                move.w  (a1)+,d0
                add.w   a3,d0
                move.w  d0,(a2)+
                move.w  (a1)+,d0
                add.w   d3,d0
                andi.w  #$1FF,d0
                bne.s   +
                addq.w  #1,d0
+
                move.w  d0,(a2)+
                dbf     d1,DrawSprite_2P_Loop
; return_16DF2:
DrawSprite_2P_Done:
                rts
; ===========================================================================
; cells are double the height in 2P mode, so halve the number of rows

; byte_16DF4:
SpriteSizes_2P:
                dc.b    0,0
                dc.b    1,1
                dc.b    4,4
                dc.b    5,5
                dc.b    8,8
                dc.b    9,9
                dc.b    $C,$C
                dc.b    $D,$D
; ===========================================================================
; loc_16E04:
DrawSprite_2P_FlipX:
                btst    #1,d4
                bne.w   DrawSprite_2P_FlipXY

-
                move.b  (a1)+,d0
                ext.w   d0
                add.w   d2,d0
                move.w  d0,(a2)+
                move.b  (a1)+,d4
                move.b  SpriteSizes_2P(pc,d4.w),(a2)+
                addq.b  #1,d5
                move.b  d5,(a2)+
                addq.w  #2,a1
                move.w  (a1)+,d0
                add.w   a3,d0
                eori.w  #$800,d0
                move.w  d0,(a2)+
                move.w  (a1)+,d0
                neg.w   d0
                move.b  byte_16E46(pc,d4.w),d4
                sub.w   d4,d0
                add.w   d3,d0
                andi.w  #$1FF,d0
                bne.s   +
                addq.w  #1,d0
+
                move.w  d0,(a2)+
                dbf     d1,-
+
                rts
; ===========================================================================
; offsets for horizontally mirrored sprite pieces (2P)
byte_16E46:
                dc.b    8,  8,  8,  8                   ; 4
                dc.b    $10,$10,$10,$10                 ; 8
                dc.b    $18,$18,$18,$18                 ; 12
                dc.b    $20,$20,$20,$20                 ; 16
; offsets for vertically mirrored sprite pieces (2P)
byte_16E56:
                dc.b    8,$10,$18,$20                   ; 4
                dc.b    8,$10,$18,$20                   ; 8
                dc.b    8,$10,$18,$20                   ; 12
                dc.b    8,$10,$18,$20                   ; 16
; ===========================================================================
; loc_16E66:
DrawSprite_2P_FlipY:
-
                move.b  (a1)+,d0
                move.b  (a1),d4
                ext.w   d0
                neg.w   d0
                move.b  byte_16E56(pc,d4.w),d4
                sub.w   d4,d0
                add.w   d2,d0
                move.w  d0,(a2)+
                move.b  (a1)+,d4
                move.b  SpriteSizes_2P_2(pc,d4.w),(a2)+
                addq.b  #1,d5
                move.b  d5,(a2)+
                addq.w  #2,a1
                move.w  (a1)+,d0
                add.w   a3,d0
                eori.w  #$1000,d0
                move.w  d0,(a2)+
                move.w  (a1)+,d0
                add.w   d3,d0
                andi.w  #$1FF,d0
                bne.s   +
                addq.w  #1,d0
+
                move.w  d0,(a2)+
                dbf     d1,-
+
                rts
; ===========================================================================
; cells are double the height in 2P mode, so halve the number of rows

; byte_16EA2:
SpriteSizes_2P_2:
                dc.b    0,0
                dc.b    1,1                             ; 2
                dc.b    4,4                             ; 4
                dc.b    5,5                             ; 6
                dc.b    8,8                             ; 8
                dc.b    9,9                             ; 10
                dc.b    $C,$C                           ; 12
                dc.b    $D,$D                           ; 14
; offsets for vertically mirrored sprite pieces (2P)
byte_16EB2:
                dc.b    8,$10,$18,$20                   ; 4
                dc.b    8,$10,$18,$20                   ; 8
                dc.b    8,$10,$18,$20                   ; 12
                dc.b    8,$10,$18,$20                   ; 16
; ===========================================================================
; loc_16EC2:
DrawSprite_2P_FlipXY:
-
                move.b  (a1)+,d0
                move.b  (a1),d4
                ext.w   d0
                neg.w   d0
                move.b  byte_16EB2(pc,d4.w),d4
                sub.w   d4,d0
                add.w   d2,d0
                move.w  d0,(a2)+
                move.b  (a1)+,d4
                move.b  SpriteSizes_2P_2(pc,d4.w),(a2)+
                addq.b  #1,d5
                move.b  d5,(a2)+
                addq.w  #2,a1
                move.w  (a1)+,d0
                add.w   a3,d0
                eori.w  #$1800,d0
                move.w  d0,(a2)+
                move.w  (a1)+,d0
                neg.w   d0
                move.b  byte_16F06(pc,d4.w),d4
                sub.w   d4,d0
                add.w   d3,d0
                andi.w  #$1FF,d0
                bne.s   +
                addq.w  #1,d0
+
                move.w  d0,(a2)+
                dbf     d1,-
+
                rts
; End of function DrawSprite_2P

; ===========================================================================
; offsets for horizontally mirrored sprite pieces (2P)
byte_16F06:
                dc.b    8,  8,  8,  8                   ; 4
                dc.b    $10,$10,$10,$10                 ; 8
                dc.b    $18,$18,$18,$18                 ; 12
                dc.b    $20,$20,$20,$20                 ; 16

; ===========================================================================
; Unused leftover code from Sonic 1: checks whether an object is off-screen

; loc_16F16:
ChkObjectVisible:
                move.w  x_pos(a0),d0                    ; a0=object
                sub.w   (Camera_X_pos).w,d0
                bmi.s   .offscreen
                cmpi.w  #screen_width,d0
                bge.s   .offscreen
                move.w  y_pos(a0),d1
                sub.w   (Camera_Y_pos).w,d1
                bmi.s   .offscreen
                cmpi.w  #screen_height,d1
                bge.s   .offscreen
                moveq   #0,d0
                rts

.offscreen:
                moveq   #1,d0
                rts
; ===========================================================================
; Unused leftover code from Sonic 1: checks whether an object is off-screen
; with more precision than the above code, taking the object's width into account

; loc_16F3E:
ChkPartiallyVisible:
                moveq   #0,d1
                move.b  width_pixels(a0),d1             ; a0=object
                move.w  x_pos(a0),d0
                sub.w   (Camera_X_pos).w,d0
                add.w   d1,d0
                bmi.s   .offscreen
                add.w   d1,d1
                sub.w   d1,d0
                cmpi.w  #screen_width,d0
                bge.s   .offscreen
                move.w  y_pos(a0),d1
                sub.w   (Camera_Y_pos).w,d1
                bmi.s   .offscreen
                cmpi.w  #screen_height,d1
                bge.s   .offscreen
                moveq   #0,d0
                rts

.offscreen:
                moveq   #1,d0
                rts
; ===========================================================================

                jmpTos  JmpTo_BuildHUD,JmpTo_BuildHUD_P1,JmpTo_BuildHUD_P2

; ===========================================================================
; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen
; as you move through the level, and otherwise updates them
; ----------------------------------------------------------------------------

; loc_16F88:
