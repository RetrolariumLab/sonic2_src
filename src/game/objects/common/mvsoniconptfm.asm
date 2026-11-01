MvSonicOnPtfm:
                move.w  y_pos(a0),d0
                sub.w   d3,d0
                bra.s   loc_19BA2
; ===========================================================================
; a couple lines of unused/leftover/dead code from Sonic 1 ; a0=object
                move.w  y_pos(a0),d0
                subi.w  #9,d0

loc_19BA2:
                tst.b   obj_control(a1)
                bmi.s   CommonPlatformCarry_Return
                cmpi.b  #6,routine(a1)
                bhs.s   CommonPlatformCarry_Return
                tst.w   (Debug_placement_mode).w
                bne.s   CommonPlatformCarry_Return
                moveq   #0,d1
                move.b  y_radius(a1),d1
                sub.w   d1,d0
                move.w  d0,y_pos(a1)
                sub.w   x_pos(a0),d2
                sub.w   d2,x_pos(a1)

CommonPlatformCarry_Return:
                rts
; ===========================================================================
; loc_19BCC:
MvSonicOnSlope:
                btst    #status.player.on_object,status(a1)
                beq.s   CommonPlatformCarry_Return_Variant2
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                lsr.w   #1,d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   loc_19BEC
                not.w   d0
                add.w   d1,d0

loc_19BEC:
                move.b  (a2,d0.w),d1
                ext.w   d1
                move.w  y_pos(a0),d0
                sub.w   d1,d0
                moveq   #0,d1
                move.b  y_radius(a1),d1
                sub.w   d1,d0
                move.w  d0,y_pos(a1)
                sub.w   x_pos(a0),d2
                sub.w   d2,x_pos(a1)

CommonPlatformCarry_Return_Variant2:
                rts
; ===========================================================================
; unused/dead code
; loc_19C0E:
MvSonicOnDoubleSlope:
                btst    #status.player.on_object,status(a1)
                beq.s   CommonPlatformCarry_Return_Variant2
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   loc_19C2C
                not.w   d0
                add.w   d1,d0

loc_19C2C:
                andi.w  #$FFFE,d0
                bra.s   loc_19BEC
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
;
; input variables:
; d1 = object width
; d3 = object height / 2
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = Sonic or Tails (set inside these subroutines)
; loc_19C32:
