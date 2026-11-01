SwScrl_Minimal:
; Set the flags to dynamically load the background as it moves
                move.w  (Camera_X_pos_diff).w,d4
                ext.l   d4
                asl.l   #5,d4
                move.w  (Camera_Y_pos_diff).w,d5
                ext.l   d5
                asl.l   #6,d5
                bsr.w   SetHorizVertiScrollFlagsBG

; Update the background's vertical scrolling
                move.w  (Camera_BG_Y_pos).w,(Vscroll_Factor_BG).w

; Update the background's (and foreground's) horizontal scrolling
; This is very basic: there is no parallax effect here
                lea     (Horiz_Scroll_Buf).w,a1
                move.w  #screen_height-1,d1
                move.w  (Camera_X_pos).w,d0
                neg.w   d0
                swap    d0
                move.w  (Camera_BG_X_pos).w,d0
                neg.w   d0

-               move.l  d0,(a1)+
                dbf     d1,-

                rts
; ===========================================================================
; unused
; loc_D69E:
SwScrl_HPZ_Continued:
                lea     (Horiz_Scroll_Buf).w,a1

; The '+1' is so that, if one block is partially-offscreen at the
; top, then another will fill the gap at the bottom of the screen
; This causes 'Horiz_Scroll_Buf' to overflow due to a lack of
; bounds-checking. This was likely a deliberate optimisation. Still,
; it's possible to avoid this without any performance penalty with a
; little extra code. See below
                move.w  #screen_height/block_height+1-1,d1

; Set up the foreground part of the horizontal scroll value
                move.w  (Camera_X_pos).w,d0
                neg.w   d0
                swap    d0

                andi.w  #$F,d2

; Turn d2 into an offset into '.doPartialLineBlock' (each instruction
; is 2 bytes long)
                add.w   d2,d2
; Get line block scroll value
                move.w  (a2)+,d0
; Output the first line block
                jmp     .doPartialLineBlock(pc,d2.w)
; ===========================================================================

.doFullLineBlock:
; Get next line block scroll value
                move.w  (a2)+,d0

; This works like a Duff's Device
.doPartialLineBlock:
                rept    16
                move.l  d0,(a1)+
                endm
                dbf     d1,.doFullLineBlock

                rts

; ---------------------------------------------------------------------------
; Subroutine to set horizontal scroll flags
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_D6E2:
