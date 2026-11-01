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
PlatformObject:
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                movem.l d1-d4,-(sp)
                bsr.s   PlatformObject_SingleCharacter
                movem.l (sp)+,d1-d4
                lea     (Sidekick).w,a1                 ; a1=character
                addq.b  #1,d6
; loc_19C48:
PlatformObject_SingleCharacter:
                btst    d6,status(a0)
                beq.w   PlatformObject_cont
                move.w  d1,d2
                add.w   d2,d2
                btst    #status.player.in_air,status(a1)
                bne.s   +
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.s   +
                cmp.w   d2,d0
                blo.s   loc_19C80
+

                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    d6,status(a0)
                moveq   #0,d4
                rts
; ---------------------------------------------------------------------------
loc_19C80:
                move.w  d4,d2
                bsr.w   MvSonicOnPtfm
                moveq   #0,d4
                rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a sloped platform like a seesaw
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
;
; input variables:
; d1 = object width
; d3 = object height
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = Sonic or Tails (set inside these subroutines)
; a2 = height data for slope
; loc_19C8A: SlopeObject:
SlopedPlatform:
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                movem.l d1-d4,-(sp)
                bsr.s   SlopedPlatform_SingleCharacter
                movem.l (sp)+,d1-d4
                lea     (Sidekick).w,a1                 ; a1=character
                addq.b  #1,d6
; loc_19CA0:
SlopedPlatform_SingleCharacter:
                btst    d6,status(a0)
                beq.w   SlopedPlatform_cont
                move.w  d1,d2
                add.w   d2,d2
                btst    #status.player.in_air,status(a1)
                bne.s   loc_19CC4
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.s   loc_19CC4
                cmp.w   d2,d0
                blo.s   loc_19CD8

loc_19CC4:
                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    d6,status(a0)
                moveq   #0,d4
                rts
; ---------------------------------------------------------------------------
loc_19CD8:
                move.w  d4,d2
                bsr.w   MvSonicOnSlope
                moveq   #0,d4
                rts
; ===========================================================================
; Identical to PlatformObject
; loc_19CE2:
PlatformObject2:
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                movem.l d1-d4,-(sp)
                bsr.s   PlatformObject_UpdateStandingPlayer
                movem.l (sp)+,d1-d4
                lea     (Sidekick).w,a1                 ; a1=character
                addq.b  #1,d6

PlatformObject_UpdateStandingPlayer:
                btst    d6,status(a0)
                beq.w   PlatformObject2_cont
                move.w  d1,d2
                add.w   d2,d2
                btst    #status.player.in_air,status(a1)
                bne.s   loc_19D1C
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.s   loc_19D1C
                cmp.w   d2,d0
                blo.s   loc_19D30

loc_19D1C:
                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    d6,status(a0)
                moveq   #0,d4
                rts
; ===========================================================================

loc_19D30:
                move.w  d4,d2
                bsr.w   MvSonicOnPtfm
                moveq   #0,d4
                rts
; ===========================================================================
; Almost identical to PlatformObject, except that this function does nothing if
; the character is already standing on a platform. Used only by the elevators
; in CNZ
; loc_19D3A:
PlatformObjectD5:
                lea     (MainCharacter).w,a1            ; a1=character
                moveq   #p1_standing_bit,d6
                movem.l d1-d4,-(sp)
                bsr.s   PlatformObject_ResolvePlayerContact
                movem.l (sp)+,d1-d4
                lea     (Sidekick).w,a1                 ; a1=character
                addq.b  #1,d6

PlatformObject_ResolvePlayerContact:
                btst    d6,status(a0)
                bne.s   loc_19D62
                btst    #status.player.on_object,status(a1)
                bne.s   loc_19D8E
                bra.w   PlatformObject_cont
; ===========================================================================

loc_19D62:
                move.w  d1,d2
                add.w   d2,d2
                btst    #status.player.in_air,status(a1)
                bne.s   loc_19D7E
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.s   loc_19D7E
                cmp.w   d2,d0
                blo.s   loc_19D92

loc_19D7E:
                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    d6,status(a0)

loc_19D8E:
                moveq   #0,d4
                rts
; ===========================================================================

loc_19D92:
                move.w  d4,d2
                bsr.w   MvSonicOnPtfm
                moveq   #0,d4
                rts
; ===========================================================================
; Used only by EHZ/HPZ log bridges. Very similar to PlatformObject_cont, but
; d2 already has the full width of the log
; loc_19D9C:
PlatformObject11_cont:
                tst.w   y_vel(a1)
                bmi.w   CommonPlatformObject_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.w   CommonPlatformObject_Return
                cmp.w   d2,d0
                bhs.w   CommonPlatformObject_Return
                bra.s   loc_19DD8
; ===========================================================================
; loc_19DBA:
PlatformObject_cont:
                tst.w   y_vel(a1)
                bmi.w   CommonPlatformObject_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.w   CommonPlatformObject_Return
                add.w   d1,d1
                cmp.w   d1,d0
                bhs.w   CommonPlatformObject_Return

loc_19DD8:
                move.w  y_pos(a0),d0
                sub.w   d3,d0
; loc_19DDE:
PlatformObject_ChkYRange:
                move.w  y_pos(a1),d2
                move.b  y_radius(a1),d1
                ext.w   d1
                add.w   d2,d1
                addq.w  #4,d1
                sub.w   d1,d0
                bhi.w   CommonPlatformObject_Return
                cmpi.w  #-$10,d0
                blo.w   CommonPlatformObject_Return
                tst.b   obj_control(a1)
                bmi.w   CommonPlatformObject_Return
                cmpi.b  #6,routine(a1)
                bhs.w   CommonPlatformObject_Return
                add.w   d0,d2
                addq.w  #3,d2
                move.w  d2,y_pos(a1)
; loc_19E14:
RideObject_SetRide:
                btst    #status.player.on_object,status(a1)
                beq.s   loc_19E30
                moveq   #0,d0
                move.b  interact(a1),d0
                if      object_size=$40
                lsl.w   #object_size_bits,d0
                else
                mulu.w  #object_size,d0
                endif
                addi.l  #Object_RAM,d0
                movea.l d0,a3                           ; a3=object
                bclr    d6,status(a3)

loc_19E30:
                if      object_size<>$40
                moveq   #0,d0                           ; Clear the high word for the coming division
                endif
                move.w  a0,d0
                subi.w  #Object_RAM,d0
                if      object_size=$40
                lsr.w   #object_size_bits,d0
                else
                divu.w  #object_size,d0
                endif
                andi.w  #$7F,d0
                move.b  d0,interact(a1)
                move.b  #0,angle(a1)
                move.w  #0,y_vel(a1)
                move.w  x_vel(a1),inertia(a1)
                btst    #status.player.in_air,status(a1)
                beq.s   loc_19E7E
                move.l  a0,-(sp)
                movea.l a1,a0
                move.w  a0,d1
                subi.w  #Object_RAM,d1
                bne.s   loc_19E76
                cmpi.w  #2,(Player_mode).w
                beq.s   loc_19E76
                jsr     (Sonic_ResetOnFloor_Part2).l
                bra.s   loc_19E7C
; ===========================================================================

loc_19E76:
                jsr     (Tails_ResetOnFloor_Part2).l

loc_19E7C:
                movea.l (sp)+,a0                        ; a0=character

loc_19E7E:
                bset    #status.player.on_object,status(a1)
                bclr    #status.player.in_air,status(a1)
                bset    d6,status(a0)

CommonPlatformObject_Return:
                rts
; ===========================================================================
; loc_19E90:
SlopedPlatform_cont:
                tst.w   y_vel(a1)
                bmi.w   CommonPlatformObject_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.s   CommonPlatformObject_Return
                add.w   d1,d1
                cmp.w   d1,d0
                bhs.s   CommonPlatformObject_Return
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   loc_19EB6
                not.w   d0
                add.w   d1,d0

loc_19EB6:
                lsr.w   #1,d0
                move.b  (a2,d0.w),d3
                ext.w   d3
                move.w  y_pos(a0),d0
                sub.w   d3,d0
                bra.w   PlatformObject_ChkYRange
; ===========================================================================
; Basically identical to PlatformObject_cont
; loc_19EC8:
PlatformObject2_cont:
                tst.w   y_vel(a1)
                bmi.w   CommonPlatformObject_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                add.w   d1,d0
                bmi.w   CommonPlatformObject_Return
                add.w   d1,d1
                cmp.w   d1,d0
                bhs.w   CommonPlatformObject_Return
                move.w  y_pos(a0),d0
                sub.w   d3,d0
                bra.w   PlatformObject_ChkYRange
; ===========================================================================
; If a character is being dragged through terrain by this object, drop the
; character on terrain instead
; loc_19EF0:
DropOnFloor:
                lea     (MainCharacter).w,a1            ; a1=character
                btst    #p1_standing_bit,status(a0)
                beq.s   loc_19F1E
                jsr     (ChkFloorEdge2).l
                tst.w   d1
                beq.s   loc_19F08
                bpl.s   loc_19F1E

loc_19F08:
                lea     (MainCharacter).w,a1            ; a1=character
                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #p1_standing_bit,status(a0)

loc_19F1E:
                lea     (Sidekick).w,a1                 ; a1=character
                btst    #p2_standing_bit,status(a0)
                beq.s   loc_19F4C
                jsr     (ChkFloorEdge2).l
                tst.w   d1
                beq.s   loc_19F36
                bpl.s   loc_19F4C

loc_19F36:
                lea     (Sidekick).w,a1                 ; a1=character
                bclr    #status.player.on_object,status(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #p2_standing_bit,status(a0)

loc_19F4C:
                moveq   #0,d4
                rts

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 01 - Sonic
; ----------------------------------------------------------------------------
; Sprite_19F50: Object_Sonic:
